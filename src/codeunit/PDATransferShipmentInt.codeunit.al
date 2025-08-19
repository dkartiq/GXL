codeunit 50253 "GXL PDA-Transfer Shipment Int."
{
    Permissions = tabledata "GXL PDA-Trans Shipment Line" = rmid;

    trigger OnRun()
    begin

    end;

    var
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        // << Upgrade
        inputStream: InStream;
        outputStream: OutStream;


    local procedure SaveInputXml(xmlInput: BigText)
    begin
        // >> Upgrade
        //TempBlob.Blob.CreateOutStream(outputStream, TextEncoding::UTF16);
        TempBlob.CreateOutStream(outputStream, TextEncoding::UTF16);
        // << Upgrade
        xmlInput.Write(outputStream);
        // >> Upgrade
        //TempBlob.Blob.CreateInStream(inputStream, TextEncoding::UTF16);
        TempBlob.CreateInStream(inputStream, TextEncoding::UTF16);
        // << Upgrade
    end;


    procedure ShipTransfer(DocumentNumber: Code[20])
    begin
        CheckTransferCanBeShipped(DocumentNumber);
        InsertTransferShipmentLine(DocumentNumber);
    end;


    procedure ShipTransferLines(DocumentNumber: Code[20]; xmlInput: BigText)
    var
        NewTempPDATransShptLine: Record "GXL PDA-Trans Shipment Line" temporary;
        xmlInbound: XmlPort "GXL PDA-Transfer Shpt. Line";
    begin
        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        xmlInbound.Import();
        xmlInbound.GetTempPDATransShptLine(NewTempPDATransShptLine);

        if NewTempPDATransShptLine.FindSet() then
            repeat
                CheckTransferCanBeShipped(NewTempPDATransShptLine);
            until NewTempPDATransShptLine.Next() = 0;

        if NewTempPDATransShptLine.FindSet() then
            repeat
                InsertTransferShipmentLine(NewTempPDATransShptLine);
            until NewTempPDATransShptLine.Next() = 0;
        NewTempPDATransShptLine.DeleteAll();
    end;

    local procedure InsertTransferShipmentLine(OrderNo: Code[20])
    var
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
        TransLine: Record "Transfer Line";
    begin
        TransLine.SetRange("Document No.", OrderNo);
        TransLine.SetRange("Derived From Line No.", 0);
        TransLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        if TransLine.FindSet() then
            repeat
                PDATransShptLine.Init();
                PDATransShptLine."No." := TransLine."Document No.";
                PDATransShptLine."Line No." := TransLine."Line No.";
                PDATransShptLine."Item No." := TransLine."Item No.";
                PDATransShptLine."Unit of Measure Code" := TransLine."Unit of Measure Code";
                PDATransShptLine.Quantity := TransLine."Outstanding Quantity";
                PDATransShptLine."Shipment Date" := WorkDate();
                //PS-2046+
                PDATransShptLine."MIM User ID" := UserId();
                //PS-2046-
                PDATransShptLine.Insert(true);
            until TransLine.Next() = 0;
    end;

    local procedure InsertTransferShipmentLine(NewPDATransShptLine: Record "GXL PDA-Trans Shipment Line")
    var
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
    begin
        if PDATransShptLine.Get(NewPDATransShptLine."No.", NewPDATransShptLine."Line No.") then begin
            PDATransShptLine.Quantity += NewPDATransShptLine.Quantity;
            //PS-2046+
            PDATransShptLine."MIM User ID" := UserId();
            //PS-2046-
            PDATransShptLine.Modify();
        end else begin
            PDATransShptLine.Init();
            PDATransShptLine := NewPDATransShptLine;
            PDATransShptLine."Shipment Date" := WorkDate();
            PDATransShptLine.Insert(true);
        end;

    end;

    local procedure CheckTransferCanBeShipped(OrderNo: Code[20])
    var
        TransHead: Record "Transfer Header";
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
    begin
        TransHead.Get(OrderNo);

        PDATransShptLine.SetRange("No.", OrderNo);
        if not PDATransShptLine.IsEmpty() then
            Error('Transfer Order %1 has already been sent to be shipped.');

    end;

    local procedure CheckTransferCanBeShipped(NewTempPDATransShptLine: Record "GXL PDA-Trans Shipment Line")
    var
        TransLine: Record "Transfer Line";
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
        OutstandingQty: Decimal;
    begin
        TransLine.Get(NewTempPDATransShptLine."No.", NewTempPDATransShptLine."Line No.");

        OutstandingQty := TransLine."Outstanding Quantity";
        if PDATransShptLine.Get(NewTempPDATransShptLine."No.", NewTempPDATransShptLine."Line No.") then
            OutstandingQty := OutstandingQty - PDATransShptLine.Quantity;

        if NewTempPDATransShptLine.Quantity > OutstandingQty then
            Error('%1 is greater than %2=%3 (Item No.=%4)',
                TransLine.FieldCaption("Qty. to Ship"), TransLine.FieldCaption("Outstanding Quantity"),
                OutstandingQty, NewTempPDATransShptLine."Item No.");
    end;

    //PS-2411+
    procedure ShipTransfer(DocumentNumber: Code[20]; var output: XmlPort "GXL PDA-TransferShptResult")
    var
        NewTempPDATransShptLine: Record "GXL PDA-Trans Shipment Line" temporary;
    begin
        CheckTransferCanBeShipped(DocumentNumber);

        NewTempPDATransShptLine.Reset();
        NewTempPDATransShptLine.DeleteAll();
        InsertTransferShipmentLine(DocumentNumber, NewTempPDATransShptLine);

        output.SetResultTransShptLine(NewTempPDATransShptLine);
    end;

    procedure ShipTransferLines(DocumentNumber: Code[20]; var xmlInput: BigText; output: XmlPort "GXL PDA-TransferShptResult")
    var
        NewTempPDATransShptLine: Record "GXL PDA-Trans Shipment Line" temporary;
        TransLine: Record "Transfer Line";
        TempLine: Record "Transfer Line" temporary;
        xmlInbound: XmlPort "GXL PDA-Transfer Shpt. Line";
        ErrFound: Boolean;
        ErrMsg: Text;
    begin
        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        xmlInbound.Import();
        xmlInbound.GetTempPDATransShptLine(NewTempPDATransShptLine);

        if NewTempPDATransShptLine.FindSet() then
            repeat
                if NewTempPDATransShptLine.Quantity <> 0 then begin
                    TransLine.Get(DocumentNumber, NewTempPDATransShptLine."Line No.");
                    CheckTransferCanBeShipped(NewTempPDATransShptLine, TransLine);
                    //PS-2474+
                    /*
                    if not CheckStockAvailable(NewTempPDATransShptLine, TransLine) then begin
                        NewTempPDATransShptLine.Modify();
                        ErrFound := true;
                    end;
                    */
                    TempLine.Reset();
                    TempLine.SetRange("Item No.", TransLine."Item No.");
                    if TempLine.FindFirst() then begin
                        TempLine."Qty. to Ship (Base)" += Round(NewTempPDATransShptLine.Quantity * TransLine."Qty. per Unit of Measure", 0.00001);
                        TempLine.Modify();
                    end else begin
                        TempLine.Init();
                        TempLine := TransLine;
                        TempLine."Qty. to Ship (Base)" := Round(NewTempPDATransShptLine.Quantity * TransLine."Qty. per Unit of Measure", 0.00001);
                        TempLine.Insert();
                    end;
                    //PS-2474-
                end;
            until NewTempPDATransShptLine.Next() = 0;

        //PS-2474+
        TempLine.Reset();
        if TempLine.FindSet() then
            repeat
                if not CheckStockAvailable(TempLine, ErrMsg) then begin
                    //PS-2478+
                    //Wrong item
                    //NewTempPDATransShptLine.SetRange("Item No.", TransLine."Item No.");
                    NewTempPDATransShptLine.SetRange("Item No.", TempLine."Item No.");
                    //PS-2478-
                    NewTempPDATransShptLine.ModifyAll(Comment, ErrMsg);
                    ErrFound := true;
                end;
            until TempLine.Next() = 0;
        NewTempPDATransShptLine.Reset();
        TempLine.DeleteAll();
        //PS-2474-

        if not ErrFound then
            if NewTempPDATransShptLine.FindSet() then
                repeat
                    InsertTransferShipmentLine(NewTempPDATransShptLine);
                until NewTempPDATransShptLine.Next() = 0;

        output.SetResultTransShptLine(NewTempPDATransShptLine);

    end;

    local procedure InsertTransferShipmentLine(OrderNo: Code[20]; var NewTempPDATransShptLine: Record "GXL PDA-Trans Shipment Line" temporary)
    var
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
        TransLine: Record "Transfer Line";
        TempLine: Record "Transfer Line" temporary;
        ErrFound: Boolean;
        ErrMsg: Text;
    begin
        TransLine.SetRange("Document No.", OrderNo);
        TransLine.SetRange("Derived From Line No.", 0);
        TransLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        if TransLine.FindSet() then
            repeat
                NewTempPDATransShptLine.Init();
                NewTempPDATransShptLine."No." := TransLine."Document No.";
                NewTempPDATransShptLine."Line No." := TransLine."Line No.";
                NewTempPDATransShptLine."Item No." := TransLine."Item No.";
                NewTempPDATransShptLine."Unit of Measure Code" := TransLine."Unit of Measure Code";
                NewTempPDATransShptLine.Quantity := TransLine."Outstanding Quantity";
                //PS-2474+
                //if not CheckStockAvailable(NewTempPDATransShptLine, TransLine) then
                //    ErrFound := true;
                //PS-2474-
                NewTempPDATransShptLine.Insert();

                //PS-2474+
                TempLine.Reset();
                TempLine.SetRange("Item No.", TransLine."Item No.");
                if TempLine.FindFirst() then begin
                    TempLine."Qty. to Ship (Base)" += TransLine."Outstanding Qty. (Base)";
                    TempLine.Modify();
                end else begin
                    TempLine.Init();
                    TempLine := TransLine;
                    TempLine."Qty. to Ship (Base)" := TransLine."Outstanding Qty. (Base)";
                    TempLine.Insert();
                end;
            //PS-2474-

            until TransLine.Next() = 0;

        //PS-2474+
        TempLine.Reset();
        if TempLine.FindSet() then
            repeat
                if not CheckStockAvailable(TempLine, ErrMsg) then begin
                    //PS-2478+
                    //Wrong item
                    //NewTempPDATransShptLine.SetRange("Item No.", TransLine."Item No.");
                    NewTempPDATransShptLine.SetRange("Item No.", TempLine."Item No.");
                    //PS-2478-
                    NewTempPDATransShptLine.ModifyAll(Comment, ErrMsg);
                    ErrFound := true;
                end;
            until TempLine.Next() = 0;
        NewTempPDATransShptLine.Reset();
        TempLine.DeleteAll();
        //PS-2474-

        if not ErrFound then begin
            if NewTempPDATransShptLine.FindSet() then
                repeat
                    PDATransShptLine.Init();
                    PDATransShptLine := NewTempPDATransShptLine;
                    PDATransShptLine."Shipment Date" := WorkDate();
                    PDATransShptLine."MIM User ID" := UserId();
                    PDATransShptLine.Insert(true);
                until NewTempPDATransShptLine.Next() = 0;
        end;
    end;

    local procedure CheckTransferCanBeShipped(var NewTempPDATransShptLine: Record "GXL PDA-Trans Shipment Line"; TransLine: Record "Transfer Line")
    var
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
        OutstandingQty: Decimal;
    begin
        OutstandingQty := TransLine."Outstanding Quantity";
        if PDATransShptLine.Get(NewTempPDATransShptLine."No.", NewTempPDATransShptLine."Line No.") then
            OutstandingQty := OutstandingQty - PDATransShptLine.Quantity;

        if NewTempPDATransShptLine.Quantity > OutstandingQty then
            Error('%1 is greater than %2=%3 (Item No.=%4)',
                TransLine.FieldCaption("Qty. to Ship"), TransLine.FieldCaption("Outstanding Quantity"),
                OutstandingQty, NewTempPDATransShptLine."Item No.");
    end;

    local procedure CheckStockAvailable(var NewTempPDATransShptLine: Record "GXL PDA-Trans Shipment Line"; TransLine: Record "Transfer Line"): Boolean
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        PDAItemInt: Codeunit "GXL PDA-Item Integration";
        QtyOnHand: Decimal;
        QtyToShipBase: Decimal;
    begin
        Item.Get(NewTempPDATransShptLine."Item No.");
        Item.SetFilter("Location Filter", TransLine."Transfer-from Code");
        Item.CalcFields(Inventory);
        SKU.Init();
        SKU."Item No." := Item."No.";
        SKU."Location Code" := TransLine."Transfer-from Code";
        QtyOnHand := Item.Inventory - PDAItemInt.GetCommittedQtyItemCheck(SKU);
        QtyToShipBase := Round(NewTempPDATransShptLine.Quantity * TransLine."Qty. per Unit of Measure", 0.00001);
        if QtyOnHand < QtyToShipBase then begin
            QtyOnHand := Round(QtyOnHand / TransLine."Qty. per Unit of Measure", 0.00001);
            NewTempPDATransShptLine.Comment := StrSubstNo('Item has insufficient stock (%1)', QtyOnHand);
            exit(false);
        end;

        exit(true);
    end;
    //PS-2411-

    //PS-2474+
    local procedure CheckStockAvailable(TransLine: Record "Transfer Line"; var ErrMsg: Text): Boolean
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        PDAItemInt: Codeunit "GXL PDA-Item Integration";
        QtyOnHand: Decimal;
        QtyToShipBase: Decimal;
    begin
        ErrMsg := '';
        Item.Get(TransLine."Item No.");
        Item.SetFilter("Location Filter", TransLine."Transfer-from Code");
        Item.CalcFields(Inventory);
        SKU.Init();
        SKU."Item No." := Item."No.";
        SKU."Location Code" := TransLine."Transfer-from Code";
        QtyOnHand := Item.Inventory - PDAItemInt.GetCommittedQtyItemCheck(SKU);
        QtyToShipBase := TransLine."Qty. to Ship (Base)";
        if QtyOnHand < QtyToShipBase then begin
            ErrMsg := StrSubstNo('Item has insufficient stock (%1 %2)', QtyOnHand, Item."Base Unit of Measure");
            exit(false);
        end;

        exit(true);
    end;
    //PS-2474-

}