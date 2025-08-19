codeunit 50252 "GXL PDA-Staging TO-to-TO"
{
    TableNo = "GXL PDA-Staging Trans. Header";

    trigger OnRun()
    begin
        PDAStagingTH := Rec;
        PDAStagingTH.TestOrderStatusApproved();
        CreateTransferOrder();
        DeleteStagingDocument();
        Rec := PDAStagingTH;
    end;

    var
        PDAStagingTH: Record "GXL PDA-Staging Trans. Header";
        PDAStagingTL: Record "GXL PDA-Staging Trans. Line";
        TransHead: Record "Transfer Header";


    local procedure CreateTransferOrder()
    var
        ReleaseTransDoc: Codeunit "Release Transfer Document";
    begin
        PDAStagingTL.Reset();
        PDAStagingTL.SetRange("Document No.", PDAStagingTH."No.");
        if PDAStagingTL.FindSet() then begin
            CreateTransferHeader();
            repeat
                CreateTransferLine(PDAStagingTL);
            until PDAStagingTL.Next() = 0;
            ReleaseTransDoc.Run(TransHead);
        end;
    end;

    local procedure CreateTransferHeader()
    var
        Loc: Record Location;
        Store: Record "LSC Store";
    begin
        TransHead.Init();
        TransHead."No." := PDAStagingTH."No.";
        TransHead."Posting Date" := PDAStagingTH."Posting Date";
        TransHead."GXL Order Date" := PDAStagingTH."Order Date";
        TransHead.Insert(true);
        TransHead.SetHideValidationDialog(true);
        //Populate Store-from and Store-to to get default dimensions from store
        Loc.Get(PDAStagingTH."Transfer-from Code");
        if Loc.GetAssociatedStore(Store, true) then
            TransHead.Validate("LSC Store-from", Store."No.")
        else
            TransHead.Validate("Transfer-from Code", PDAStagingTH."Transfer-from Code");
        Loc.Get(PDAStagingTH."Transfer-to Code");
        if Loc.GetAssociatedStore(Store, true) then
            TransHead.Validate("LSC Store-to", Store."No.")
        else
            TransHead.Validate("Transfer-to Code", PDAStagingTH."Transfer-to Code");
        //Reset Store-from and Store-to
        //PS-2143+
        //Store-from and Store-to are now used for LS functionality
        //TransHead."Store-from" := '';
        //TransHead."Store-to" := '';
        //PS-2143-
        TransHead."GXL Order Status" := TransHead."GXL Order Status"::Placed;
        TransHead."GXL Created Date" := PDAStagingTH."Created Date";
        TransHead."GXL Created Time" := PDAStagingTH."Created Time";
        TransHead."GXL Created By User ID" := PDAStagingTH."Created By User ID";
        //PS-2523 VET Clinic transfer order +
        TransHead."GXL VET Store Code" := PDAStagingTH."VET Store Code";
        //PS-2523 VET Clinic transfer order -
        TransHead.Modify(true);
    end;

    local procedure CreateTransferLine(PDAStagingTL: Record "GXL PDA-Staging Trans. Line")
    var
        TransLine: Record "Transfer Line";
    begin
        TransLine.Init();
        TransLine."Document No." := TransHead."No.";
        TransLine."Line No." := PDAStagingTL."Line No.";
        TransLine.Validate("Item No.", PDAStagingTL."Item No.");
        TransLine.Validate("Unit of Measure Code", PDAStagingTL."Unit of Measure Code");
        TransLine.Validate(Quantity, PDAStagingTL.Quantity);
        TransLine.Insert(); //No run validation to avoid Line No. to be reset
    end;

    local procedure DeleteStagingDocument()
    begin
        PDAStagingTL.DeleteAll();
        PDAStagingTH.Delete();
    end;
}