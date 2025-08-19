report 50001 "GXL Reset Purch. Order Status"
{
    Caption = 'Reset Purchase Order Status';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    //TODO: link to archive, do the custom fields in archive required
    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            //TODO: Order Status - Reset Closed status to become Placed again
            DataItemTableView = sorting("GXL Order Status") where("GXL Order Status" = filter(Cancelled), "Document Type" = filter(Order));
            dataitem("Purchase Line Archive"; "Purchase Line Archive")
            {
                DataItemTableView = sorting("Document Type", "Document No.", "Doc. No. Occurrence", "Version No.", "Line No.");
                DataItemLinkReference = "Purchase Header";
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                dataitem("Purchase Line"; "Purchase Line")
                {
                    DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                    DataItemLinkReference = "Purchase Line Archive";
                    DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Line No." = field("Line No.");

                    trigger OnAfterGetRecord()
                    begin
                        "Purchase Line".SuspendStatusCheck(true);
                        "Purchase Line".SuspendOrderStatusCheck(true);
                        if (Quantity <> "Purchase Line Archive".Quantity) or ("Qty. to Receive" <> "Purchase Line Archive"."Qty. to Receive") then begin
                            if Quantity <> "Purchase Line Archive".Quantity then
                                Validate(Quantity, "Purchase Line Archive".Quantity);
                            if "Qty. to Receive" <> "Purchase Line Archive"."Qty. to Receive" then
                                Validate("Qty. to Receive", "Purchase Line Archive"."Qty. to Receive");
                            Modify(true);
                        end;
                    end;

                }

                trigger OnPreDataItem()
                begin
                    SetRange("Version No.", PurchHeaderArchive."Version No.");
                    SetRange("Doc. No. Occurrence", PurchHeaderArchive."Doc. No. Occurrence");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                PurchHeaderArchive.Reset();
                PurchHeaderArchive.SetRange("Document Type", PurchHeaderArchive."Document Type"::Order);
                PurchHeaderArchive.SetRange("No.", "No.");
                //TODO if Order Change Reason Code is required
                if PurchHeaderArchive.FindLast() then;

                PurchHeader := "Purchase Header";
                PurchHeader.Status := PurchHeader.Status::Open;
                PurchHeader."GXL Order Status" := PurchHeader."GXL Order Status"::Placed;
                PurchHeader.Modify();
            end;
        }
    }



    var
        PurchHeaderArchive: Record "Purchase Header Archive";
        PurchHeader: Record "Purchase Header";
}