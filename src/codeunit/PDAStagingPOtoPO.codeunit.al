codeunit 50259 "GXL PDA-Staging PO-to-PO"
{
    TableNo = "GXL PDA-Staging Purch. Header";

    trigger OnRun()
    begin
        PDAStagingPH := Rec;
        PDAStagingPH.TestOrderStatusApproved();
        CreatePurchaseOrder();
        DeleteStagingDocument();
        Rec := PDAStagingPH;
    end;

    var
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        PDAStagingPL: Record "GXL PDA-Staging Purch. Line";
        PurchHead: Record "Purchase Header";

    local procedure CreatePurchaseOrder()
    var
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        PDAStagingPL.Reset();
        PDAStagingPL.SetRange("Document No.", PDAStagingPH."No.");
        if PDAStagingPL.FindSet() then begin
            CreatePurchaseHeader();
            repeat
                CreatePurchaseLine(PDAStagingPL);
            until PDAStagingPL.Next() = 0;

            PurchHead.find();
            ReleasePurchDoc.PerformManualRelease(PurchHead);
        end;
    end;

    local procedure CreatePurchaseHeader()
    begin
        PurchHead.Init();
        PurchHead."Document Type" := PurchHead."Document Type"::Order;
        PurchHead."No." := PDAStagingPH."No.";
        PurchHead."Order Date" := PDAStagingPH."Order Date";
        PurchHead."Posting Date" := PDAStagingPH."Posting Date";
        //TODO: Domestic and Internaltional Order is not in scope
        PurchHead."GXL Domestic Order" := true; // >> HP2-Sprint2 <<
        PurchHead.Insert(true);

        PurchHead.Validate("Buy-from Vendor No.", PDAStagingPH."Buy-from Vendor No.");
        PurchHead.Validate("Location Code", PDAStagingPH."Location Code");
        PurchHead."GXL Source of Supply" := PurchHead."GXL Source of Supply"::SD;
        PurchHead.GXL_InitSupplyChain();
        PurchHead."GXL Created Date" := PDAStagingPH."Created Date";
        PurchHead."GXL Created Time" := PDAStagingPH."Created Time";
        PurchHead."GXL Created By User ID" := PDAStagingPH."Created By User ID";
        PurchHead."GXL Order Status" := PurchHead."GXL Order Status"::Created; //set Order Status to Created, it will be changed to Placed on release the PO
        PurchHead.Modify(true);
    end;

    local procedure CreatePurchaseLine(PDAStagingPL: Record "GXL PDA-Staging Purch. Line")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.Init();
        PurchLine."Document Type" := PurchHead."Document Type";
        PurchLine."Document No." := PurchHead."No.";
        PurchLine."Line No." := PDAStagingPL."Line No.";
        PurchLine.Type := PurchLine.Type::Item;
        PurchLine.Validate("No.", PDAStagingPL."No.");
        if PurchLine."Unit of Measure Code" <> PDAStagingPL."Unit of Measure Code" then
            PurchLine.Validate("Unit of Measure Code", PDAStagingPL."Unit of Measure Code");
        if PurchLine."Location Code" <> PDAStagingPL."Location Code" then
            PurchLine.Validate("Location Code", PDAStagingPL."Location Code");
        PurchLine.Validate(Quantity, PDAStagingPL.Quantity);
        if PurchLine."Direct Unit Cost" <> PDAStagingPL."Direct Unit Cost" then
            PurchLine.Validate("Direct Unit Cost", PDAStagingPL."Direct Unit Cost");
        if PurchLine."Line Discount %" <> PDAStagingPL."Line Discount %" then
            PurchLine.Validate("Line Discount %", PDAStagingPL."Line Discount %");
        PurchLine."GXL Qty. Variance Reason Code" := PDAStagingPL."Qty. Variance Reason Code";
        PurchLine."GXL Vendor Reorder No." := PDAStagingPL."Vendor Reorder No.";
        PurchLine.Insert();
    end;

    local procedure DeleteStagingDocument()
    begin
        PDAStagingPL.DeleteAll();
        PDAStagingPH.Delete();
    end;
}