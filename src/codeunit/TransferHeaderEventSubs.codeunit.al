codeunit 50351 "GXL Transfer Header Event Subs"
{

    //HP-2321
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptHeader', '', true, true)]
    procedure OnAfterInsertTransRcptHeader(var TransRcptHeader: Record "Transfer Receipt Header"; var TransHeader: Record "Transfer Header")
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", TransHeader."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        if TransferLine.FindSet(true) then
            repeat
                TransferLine."LSC From Dimension Set ID" := TransferLine."Dimension Set ID";
                TransferLine."LSC From Shortcut Dim. 1 Code" := TransferLine."Shortcut Dimension 1 Code";
                TransferLine."LSC From Shortcut Dim. 2 Code" := TransferLine."Shortcut Dimension 2 Code";
                TransferLine.modify;
            until TransferLine.next = 0;
    end;

    // //TESTING
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterPostItemJnlLine', '', true, true)]
    // procedure OnAfterPostItemJnlLine(ItemJnlLine: Record "Item Journal Line"; var TransLine3: Record "Transfer Line"; var TransRcptHeader2: Record "Transfer Receipt Header"; var TransRcptLine2: Record "Transfer Receipt Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    // begin
    //     Message('%1 - %2 - %3 - %4 - %5 - %6 - %7 - %8 - %9',
    //     ItemJnlLine."Item No.",
    //     ItemJnlLine."Shortcut Dimension 1 Code",
    //     ItemJnlLine."New Shortcut Dimension 1 Code",
    //     ItemJnlLine."Shortcut Dimension 2 Code",
    //     ItemJnlLine."New Shortcut Dimension 2 Code",
    //     ItemJnlLine."Dimension Set ID",
    //     ItemJnlLine."New Dimension Set ID",
    //     ItemJnlLine."Location Code",
    //     ItemJnlLine."New Location Code");
    // end;
    // //TESTING
    //HP-2321

    //#region "Transfer Header"
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterInitRecord', '', true, true)]
    local procedure OnAfterInitRecord_TransferHeader(var TransferHeader: Record "Transfer Header")
    begin
        TransferHeader.GXL_InitSupplyChain();
    end;

    //PS-2143+
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterValidateEvent', 'Transfer-from Code', true, true)]
    local procedure OnAfterValidateEvent_TransferFromCode(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header"; CurrFieldNo: Integer)
    var
        Location: Record Location;
        Store: Record "LSC Store";
        SupplyChainSetup: Record "GXL Supply Chain Setup"; // >> HP2-SPRINT <<
    begin
        if (Rec."Transfer-from Code" <> '') then begin
            IF Location.Get(Rec."Transfer-from Code") then begin
                Rec."GXL 3PL" := false;
                Location.CalcFields("GXL Location Type");
                if Location."GXL Location Type" = Location."GXL Location Type"::"3" then begin //3=DC
                    Rec."GXL Source of Supply" := Rec."GXL Source of Supply"::WH;
                    Rec."GXL 3PL" := Location."GXL 3PL Warehouse";
                    // >> HP2-SPRINT2
                    SupplyChainSetup.GET;
                    Rec."GXL Transport Type" := FORMAT(Rec."GXL Source of Supply") + SupplyChainSetup."GXL Default Transportation Mode";
                    IF Location."GXL 3PL Warehouse" THEN
                        Rec."GXL 3PL Out" := TRUE;
                    // << HP2-SPRINT2
                end;
                //Default store-from
                if Location.GetAssociatedStore(Store, true) then begin
                    Rec."LSC Store-from" := Store."No.";
                    SetStoreDimension(Rec, Rec.FieldNo("LSC Store-from"));
                end;
            end;
        end;
    end;

    local procedure SetStoreDimension(var TransferHeader: Record "Transfer Header"; pFieldNo: Integer)
    var
        SourceCodeSetup: Record "Source Code Setup";
        Store: Record "LSC Store";
        CodeDictionary: Dictionary of [Integer, Code[20]];
        DimSource: List of [Dictionary of [Integer, Code[20]]];
        DimMgt: Codeunit DimensionManagement;
    begin
        SourceCodeSetup.Get;

        if TransferHeader."LSC Store-from" <> '' then begin
            Store.Get(TransferHeader."LSC Store-from");
            CodeDictionary.Add(Database::"LSC Store", Store."No.");
            DimSource.Add(CodeDictionary);
            TransferHeader."Dimension Set ID" :=
              DimMgt.GetRecDefaultDimID(Store, 0, DimSource, SourceCodeSetup.Transfer,
              Store."Global Dimension 1 Code", Store."Global Dimension 2 Code", 0, 0);
            DimMgt.UpdateGlobalDimFromDimSetID(TransferHeader."Dimension Set ID", TransferHeader."Shortcut Dimension 1 Code", TransferHeader."Shortcut Dimension 2 Code");
        end;

        if pFieldNo = TransferHeader.FieldNo("LSC Store-to") then begin
            Store.Get(TransferHeader."LSC Store-to");
            Clear(CodeDictionary);
            Clear(DimSource);
            CodeDictionary.Add(Database::"LSC Store", Store."No.");
            DimSource.Add(CodeDictionary);
            TransferHeader."LSC New Dimension Set ID" :=
              DimMgt.GetRecDefaultDimID(Store, 0, DimSource, SourceCodeSetup.Transfer,
              Store."Global Dimension 1 Code", Store."Global Dimension 2 Code", 0, 0);
            DimMgt.UpdateGlobalDimFromDimSetID(TransferHeader."LSC New Dimension Set ID", TransferHeader."LSC New Shortcut Dim. 1 Code", TransferHeader."LSC New Shortcut Dim. 2 Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterValidateEvent', 'Transfer-to Code', true, true)]
    local procedure OnAfterValidateEvent_TransferToCode(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header"; CurrFieldNo: Integer)
    var
        Location: Record Location;
        Store: Record "LSC Store";
    begin
        //Default store-to
        Location.Code := Rec."Transfer-to Code";
        if Location.GetAssociatedStore(Store, true) then begin
            Rec."LSC Store-to" := Store."No.";
            SetStoreDimension(Rec, Rec.FieldNo("LSC Store-to"));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterValidateEvent', 'Shipment Date', true, true)]
    local procedure OnAfterValidateEvent_ShipmentDate(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header"; CurrFieldNo: Integer)
    var

        CalChange: Record "Customized Calendar Change";
        // >> Upgrade
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
        // << Upgrade
        CalendarMgt: Codeunit "Calendar Management";
        TransLT: Text;
    begin

        if Rec."Shipment Date" <> 0D then begin
            CustomCalendarChange[1].SetSource(CalChange."Source Type"::Location, Rec."Transfer-from Code", '', '');
            CustomCalendarChange[2].SetSource(CalChange."Source Type"::Location, Rec."Transfer-to Code", '', '');
            TransLT := Rec.GXL_GetTransferLeadTime(Rec."Transfer-from Code", Rec."Transfer-to Code", Rec."Shipment Date");
            Rec.Validate("GXL Expected Receipt Date",
                CalendarMgt.CalcDateBOC(
                    TransLT,
                    Rec."Shipment Date",
                    // >> Upgrade
                    // CalChange."Source Type"::Location, Rec."Transfer-from Code", '',
                    // CalChange."Source Type"::Location, Rec."Transfer-to Code", '',
                    CustomCalendarChange,
                    // << Upgrade
                    true
                ));
        end;
    end;
    //PS-2143-

    //#end region "Transfer Header"

    //#region "Transfer Line"
    //#end region "Transfer Line"

    //#region "Release Transfer Document"
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Transfer Document", 'OnBeforeReleaseTransferDoc', '', true, true)]
    local procedure OnBeforeReleaseTransferDoc(var TransferHeader: Record "Transfer Header")
    var
        WHDataManagement: Codeunit "GXL WH Data Management";
    begin
        if TransferHeader."GXL Order Status" < TransferHeader."GXL Order Status"::Placed then
            TransferHeader."GXL Order Status" := TransferHeader."GXL Order Status"::Placed;
        // >> HP2-SPRINT2  
        IF (TransferHeader."GXL 3PL") AND (NOT TransferHeader."GXL 3PL File Sent") AND (TransferHeader."GXL 3PL Out") THEN
            WHDataManagement."3PLFileTransferCheck"(TransferHeader);
        // << HP2-SPRINT2
    end;

    //TODO: Order Status
    //ERP-327 +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Transfer Document", 'OnBeforeReopenTransferDoc', '', true, true)]
    local procedure OnBeforeReopenTransferDoc(var TransferHeader: Record "Transfer Header")
    begin
        if TransferHeader."GXL Order Status" < TransferHeader."GXL Order Status"::Confirmed then
            TransferHeader."GXL Order Status" := TransferHeader."GXL Order Status"::New;
    end;
    //ERP-327 -
    //#end region "Release Transfer Document"

    //PS-2523 VET Clinic transfer order +
    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterCopyFromTransferHeader', '', true, false)]
    local procedure TransShptHead_OnAfterCopyFromTransferHeader(TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
        TransferShipmentHeader."GXL VET Store Code" := TransferHeader."GXL VET Store Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Header", 'OnAfterCopyFromTransferHeader', '', true, false)]
    local procedure TransRcptHead_OnAfterCopyFromTransferHeader(TransferHeader: Record "Transfer Header"; var TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
        TransferReceiptHeader."GXL VET Store Code" := TransferHeader."GXL VET Store Code";
    end;
    //PS-2523 VET Clinic transfer order -

    //PS-1954+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterTransferOrderPostShipment', '', true, true)]
    local procedure OnAfterTransferOrderPostShipment(var TransferHeader: Record "Transfer Header")
    var
        TransPostSingleInstance: Codeunit "GXL TransPost-SingleInstance";
    begin
        if TransferHeader.Get(TransferHeader."No.") then;   // >> upgrade SKY <<
        if (TransferHeader."Last Shipment No." <> '') and (not TransferHeader."Direct Transfer") and
            (TransferHeader."GXL Order Status" <> TransferHeader."GXL Order Status"::Confirmed) then begin
            TransferHeader.SetHideValidationDialog(true);
            TransferHeader.Validate("GXL Order Status", TransferHeader."GXL Order Status"::Confirmed);
            if TransferHeader."GXL VET Store Code" = '' then //PS-2523 VET Clinic Transfer Order +
                TransferHeader."GXL MIM User ID" := ''; //PS-2046
            TransferHeader.Modify();
            //PS-2046+
        end else begin
            if TransferHeader."GXL VET Store Code" = '' then begin //PS-2523 VET Clinic Transfer Order +
                TransferHeader."GXL MIM User ID" := '';
                TransferHeader.Modify();
            end; //PS-2523 VET Clinic Transfer Order +
            //PS-2046-
        end;
        //PS-2046+
        TransPostSingleInstance.ClearTransferHeader();
        //PS-2046-

    end;

    //PS-2523 VET Clinic transfer order +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptLine', '', true, false)]
    local procedure OnBeforeInsertTransShptLine_PostShipment(TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    begin
        TransShptLine."GXL Original Order Quantity" := TransLine.Quantity;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeInsertTransRcptLine', '', true, false)]
    local procedure OnBeforeInsertTransRcptLine_PostReceipt(TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")
    begin
        TransRcptLine."GXL Original Order Quantity" := TransLine.Quantity;
    end;
    //PS-2523 VET Clinic transfer order -

    //Complete transfer order once it has been received even there is still outstanding qty
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeDeleteOneTransferHeader', '', true, true)]
    local procedure OnBeforeDeleteOneTransferHeader_PostReceipt(TransferHeader: Record "Transfer Header"; var DeleteOne: Boolean)
    var
        InsertCancelNAVOrderLog: Codeunit "GXL Insert Cancel NAVOrder Log";
    begin
        if TransferOrderIsCompletelyReceived(TransferHeader) then begin
            TransferHeader.SetHideValidationDialog(true);
            DeleteOne := true;
        end;

        //NAV9-11+
        //Have to hook at this stage as there is no event after posting before commit found in this version
        InsertCancelNAVOrderLog.CancelNAVTransferOrder(TransferHeader);
        //NAV9-11-
    end;

    ///<Summary>
    ///Check if the transfer order has been completely received what have been shipped
    ///</Summary>
    procedure TransferOrderIsCompletelyReceived(TransferHeader: Record "Transfer Header"): Boolean
    var
        TransLine: Record "Transfer Line";
    begin
        TransLine.SetRange("Document No.", TransferHeader."No.");
        TransLine.SetRange("Derived From Line No.", 0);
        TransLine.SetFilter("Quantity Shipped", '<>0');
        if TransLine.IsEmpty() then
            exit(false);

        TransLine.SetRange("Quantity Shipped");
        if TransLine.FindSet() then begin
            repeat
                if (TransLine."Quantity Received" <> TransLine."Quantity Shipped") or
                    (TransLine."Qty. Received (Base)" <> TransLine."Qty. Shipped (Base)") then
                    exit(false);
            until TransLine.Next() = 0;
            exit(true);
        end;
        exit(false);
    end;
    //PS-1954-

    //PS-2046+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeTransferOrderPostShipment', '', true, true)]
    local procedure OnBeforeTransferOrderPostShipment(var TransferHeader: Record "Transfer Header")
    var
        TransPostSingleInstance: Codeunit "GXL TransPost-SingleInstance";
    begin
        TransPostSingleInstance.SetTransferHeader(TransferHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforePostItemJournalLine', '', true, true)]
    local procedure OnBeforePostItemJournalLine_TransferPostShipment(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    var
        TransferHeader: Record "Transfer Header";
        TransPostSingleInstance: Codeunit "GXL TransPost-SingleInstance";
    begin
        TransPostSingleInstance.GetTransferHeader(TransferHeader);
        if TransferHeader."No." = TransferLine."Document No." then
            ItemJournalLine."GXL MIM User ID" := TransferHeader."GXL MIM User ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransferOrderPostReceipt', '', true, true)]
    local procedure OnBeforeTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header")
    var
        TransPostSingleInstance: Codeunit "GXL TransPost-SingleInstance";
    begin
        TransPostSingleInstance.SetTransferHeader(TransferHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJournalLine', '', true, true)]
    local procedure OnBeforePostItemJournalLine_TransferPostReceipt(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line")
    var
        TransferHeader: Record "Transfer Header";
        TransPostSingleInstance: Codeunit "GXL TransPost-SingleInstance";
    begin
        TransPostSingleInstance.GetTransferHeader(TransferHeader);
        if TransferHeader."No." = TransferLine."Document No." then
            ItemJournalLine."GXL MIM User ID" := TransferHeader."GXL MIM User ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterTransferOrderPostReceipt', '', true, true)]
    local procedure OnAfterTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header")
    var
        TransPostSingleInstance: Codeunit "GXL TransPost-SingleInstance";
    begin
        TransferHeader."GXL MIM User ID" := '';
        if TransferHeader.Modify() then;
        TransPostSingleInstance.ClearTransferHeader();
    end;
    //PS-2046-
}