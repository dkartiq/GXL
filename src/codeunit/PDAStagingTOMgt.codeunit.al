codeunit 50251 "GXL PDA-Staging TO Mgt."
{
    Permissions = tabledata "GXL PDA-Staging Trans. Header" = imd,
         tabledata "GXL PDA-Staging Trans. Line" = imd;

    trigger OnRun()
    begin

    end;

    var
        TempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary;
        TempTransHead: Record "Transfer Header" temporary;
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


    //PS-2523 VET Clinic transfer order: Added param VETStoreCode
    procedure CreateTransfer(StoreCode: Code[10]; ToStoreCode: Code[10]; VETStoreCode: Code[20]; BatchId: Integer; xmlInput: BigText; var outboundXml: XmlPort "GXL PDA-Transfer Order")
    var
        Store: Record "LSC Store";
        NewTempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary;
        xmlInbound: XmlPort "GXL PDA-Rec Purchase Lines";
    begin
        //PS-2523 VET Clinic transfer order +
        Store.Get(ToStoreCode);
        if Store."GXL VET Store" then begin
            if VETStoreCode = '' then
                Error('VET Store Code must be specified for transfer to VET Clinic.');
        end else begin
            if VETStoreCode <> '' then
                Error('VET Store Code must not be specified.');
        end;
        //PS-2523 VET Clinic transfer order -

        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        xmlInbound.Import();
        xmlInbound.GetTempPDAPurchaseLines(NewTempPDAPurchaseLines);

        TempPDAPurchaseLines.Reset();
        TempPDAPurchaseLines.DeleteAll();
        if NewTempPDAPurchaseLines.FindSet() then
            repeat
                TempPDAPurchaseLines := NewTempPDAPurchaseLines;
                TempPDAPurchaseLines.Insert();
            until NewTempPDAPurchaseLines.Next() = 0;

        //PS-2523 VET Clinic transfer order +
        //CreatePDAStagingTransfer(StoreCode, ToStoreCode, BatchId);
        CreatePDAStagingTransfer(StoreCode, ToStoreCode, VETStoreCode, BatchId);
        //PS-2523 VET Clinic transfer order -

        outboundXml.ShowBatchTransferOrder(StoreCode, BatchId);
    end;

    //PS-2523 VET Clinic transfer order: Added param VETStoreCode
    local procedure CreatePDAStagingTransfer(StoreCode: Code[10]; ToStoreCode: Code[10]; VETStoreCode: Code[20]; BatchId: Integer)
    var
        PDAStagingTL: Record "GXL PDA-Staging Trans. Line";
        TempPDAStagingTL: Record "GXL PDA-Staging Trans. Line" temporary;
        TransLine: Record "Transfer Line";
        TempTransLine: Record "Transfer Line" temporary;
        TONumber: Code[20];
    begin
        TempPDAPurchaseLines.Reset();
        TempPDAPurchaseLines.SetFilter(QtyOrdered, '>0');
        if TempPDAPurchaseLines.FindSet() then begin
            Clear(TempTransHead);

            //PS-2523 VET Clinic transfer order +
            TONumber := CreateStagingTransHeader(StoreCode, ToStoreCode, VETStoreCode, BatchId);
            //TONumber := CreateStagingTransHeader(StoreCode, ToStoreCode, BatchId);
            //PS-2523 VET Clinic transfer order -
            repeat
                Clear(TransLine);
                TempTransHead."No." := TONumber;
                TempPDAStagingTL.Init();
                TempPDAStagingTL."Document No." := TempTransHead."No.";
                TempPDAStagingTL."Line No." := TempPDAPurchaseLines."Line No.";
                TempPDAStagingTL."Item No." := TempPDAPurchaseLines."Item No.";
                TempPDAStagingTL."Unit of Measure Code" := TempPDAPurchaseLines."Unit of Measure Code";
                TempPDAStagingTL.Quantity := TempPDAPurchaseLines.QtyOrdered;
                TempPDAStagingTL."Qty. to Receive" := TempPDAPurchaseLines.QtyToReceive;
                TempPDAStagingTL.Description := TempPDAPurchaseLines.Description;
                TempPDAStagingTL.PopulateTempTransferLine(TempTransHead, TransLine);

                TempTransLine.Init();
                TempTransLine.TransferFields(TransLine);
                TempTransLine."Line No." := TempPDAPurchaseLines."Line No.";
                if TempPDAPurchaseLines.Description <> '' then
                    TempTransLine.Description := TempPDAPurchaseLines.Description;
                TempTransLine.Insert();
            until TempPDAPurchaseLines.Next() = 0;

            TempTransLine.Reset();
            if TempTransLine.FindSet() then
                repeat
                    PDAStagingTL.Init();
                    PDAStagingTL.TransferFields(TempTransLine);
                    PDAStagingTL.Insert();
                until TempTransLine.Next() = 0;
            TempTransLine.DeleteAll();

            TempPDAPurchaseLines.DeleteAll();
        end;
    end;

    //PS-2523 VET Clinic transfer order: Added param VETStoreCode
    local procedure CreateStagingTransHeader(StoreCode: Code[10]; ToStoreCode: Code[10]; VETStoreCode: Code[20]; BatchId: Integer): Code[20]
    var
        PDAStagingTH: Record "GXL PDA-Staging Trans. Header";
        TempPDAStagingTH: Record "GXL PDA-Staging Trans. Header" temporary;
        TONumber: Code[20];
    begin
        TempPDAStagingTH.Init();
        TempPDAStagingTH."No." := '';
        TempPDAStagingTH."Transfer-from Code" := StoreCode;
        TempPDAStagingTH."Transfer-to Code" := ToStoreCode;
        TempPDAStagingTH."Order Date" := WorkDate();
        TempPDAStagingTH."Posting Date" := WorkDate();
        TempPDAStagingTH."Shipment Date" := WorkDate();
        TempPDAStagingTH."PDA Batch Id" := BatchId;
        //PS-2523 VET Clinic transfer order +
        TempPDAStagingTH."VET Store Code" := VETStoreCode;
        //PS-2523 VET Clinic transfer order -
        TempPDAStagingTH.PopulateTempTransferHeader(TempTransHead);

        PDAStagingTH.SetCurrentKey("PDA Batch Id");
        PDAStagingTH.SetRange("PDA Batch Id", BatchId);
        PDAStagingTH.SetRange("Transfer-from Code", StoreCode);
        if not PDAStagingTH.FindFirst() then begin
            Clear(PDAStagingTH);
            PDAStagingTH."No." := '';
            //PS-2523 VET Clinic transfer order +
            if VETStoreCode <> '' then
                TONumber := PDAStagingTH.GetNextTONumberVET()
            else
                //PS-2523 VET Clinic transfer order -
                TONumber := PDAStagingTH.GetNextTONumber();
            Commit(); //Release lock

            PDAStagingTH.Init();
            PDAStagingTH."No." := TONumber;
            PDAStagingTH.Insert(true);
            PDAStagingTH.TransferFields(TempTransHead, false);
            PDAStagingTH."Order Status" := PDAStagingTH."Order Status"::Approved;
            PDAStagingTH."PDA Batch Id" := BatchId;
            //PS-2523 VET Clinic transfer order +
            PDAStagingTH."VET Store Code" := VETStoreCode;
            //PS-2523 VET Clinic transfer order -
            PDAStagingTH.Modify();
        end;
        exit(PDAStagingTH."No.");
    end;

}