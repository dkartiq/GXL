codeunit 50255 "GXL PDA-Transfer Receipt Int."
{
    Permissions = tabledata "GXL PDA-Trans Receipt Line" = rmid;

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

    procedure ReceiveTransfer(DocumentNumber: Code[20])
    begin
        CheckTransferCanBeReceived(DocumentNumber);
        InsertTransferReceiptLine(DocumentNumber);
    end;


    procedure ReceiveTransferLines(DocumentNumber: Code[20]; xmlInput: BigText)
    var
        NewTempPDATransRcptLine: Record "GXL PDA-Trans Receipt Line" temporary;
        xmlInbound: XmlPort "GXL PDA-Transfer Rcpt. Line";
    begin
        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        xmlInbound.Import();
        xmlInbound.GetTempPDATransRcptLine(NewTempPDATransRcptLine);

        if NewTempPDATransRcptLine.FindSet() then
            repeat
                CheckTransferCanBeReceived(NewTempPDATransRcptLine);
            until NewTempPDATransRcptLine.Next() = 0;

        if NewTempPDATransRcptLine.FindSet() then
            repeat
                InsertTransferReceiptLine(NewTempPDATransRcptLine);
            until NewTempPDATransRcptLine.Next() = 0;
        NewTempPDATransRcptLine.DeleteAll();
    end;

    local procedure InsertTransferReceiptLine(OrderNo: Code[20])
    var
        PDATransRcptLine: Record "GXL PDA-Trans Receipt Line";
        TransLine: Record "Transfer Line";
    begin
        TransLine.SetRange("Document No.", OrderNo);
        TransLine.SetRange("Derived From Line No.", 0);
        TransLine.SetFilter("Qty. in Transit", '<>0');
        if TransLine.FindSet() then
            repeat
                PDATransRcptLine.Init();
                PDATransRcptLine."No." := TransLine."Document No.";
                PDATransRcptLine."Line No." := TransLine."Line No.";
                PDATransRcptLine."Item No." := TransLine."Item No.";
                PDATransRcptLine."Unit of Measure Code" := TransLine."Unit of Measure Code";
                PDATransRcptLine.Quantity := TransLine."Qty. in Transit";
                PDATransRcptLine."Receipt Date" := WorkDate();
                //PS-2046+
                PDATransRcptLine."MIM User ID" := UserId();
                //PS-2046-
                PDATransRcptLine.Insert(true);
            until TransLine.Next() = 0;
    end;

    local procedure InsertTransferReceiptLine(NewPDATransRcptLine: Record "GXL PDA-Trans Receipt Line")
    var
        PDATransRcptLine: Record "GXL PDA-Trans Receipt Line";
    begin
        if PDATransRcptLine.Get(NewPDATransRcptLine."No.", NewPDATransRcptLine."Line No.") then begin
            PDATransRcptLine.Quantity += NewPDATransRcptLine.Quantity;
            //PS-2046+
            PDATransRcptLine."MIM User ID" := UserId();
            //PS-2046-
            PDATransRcptLine.Modify();
        end else begin
            PDATransRcptLine.Init();
            PDATransRcptLine := NewPDATransRcptLine;
            PDATransRcptLine."Receipt Date" := WorkDate();
            PDATransRcptLine.Insert(true);
        end;

    end;

    local procedure CheckTransferCanBeReceived(OrderNo: Code[20])
    var
        TransHead: Record "Transfer Header";
        PDATransRcptLine: Record "GXL PDA-Trans Receipt Line";
    begin
        TransHead.Get(OrderNo);
        if TransHead."Direct Transfer" then
            Error('Receipt is not applicable when it is a Direct Transfer Order.');

        PDATransRcptLine.Reset();
        PDATransRcptLine.SetRange("No.", OrderNo);
        if not PDATransRcptLine.IsEmpty() then
            Error('Transfer Order %1 has already been sent to be Received.');

    end;

    local procedure CheckTransferCanBeReceived(NewTempPDATransRcptLine: Record "GXL PDA-Trans Receipt Line")
    var
        TransLine: Record "Transfer Line";
        PDATransRcptLine: Record "GXL PDA-Trans Receipt Line";
        OutstandingQty: Decimal;
    begin
        TransLine.Get(NewTempPDATransRcptLine."No.", NewTempPDATransRcptLine."Line No.");

        OutstandingQty := TransLine."Qty. in Transit";
        if PDATransRcptLine.Get(NewTempPDATransRcptLine."No.", NewTempPDATransRcptLine."Line No.") then
            OutstandingQty := OutstandingQty - PDATransRcptLine.Quantity;

        if NewTempPDATransRcptLine.Quantity > OutstandingQty then
            Error('%1 is greater than %2=%3 (Item No.=%4)',
                TransLine.FieldCaption("Qty. to Receive"), TransLine.FieldCaption("Outstanding Quantity"),
                OutstandingQty, NewTempPDATransRcptLine."Item No.");
    end;

}