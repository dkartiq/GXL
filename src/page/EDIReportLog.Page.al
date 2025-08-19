page 50382 "GXL EDI Report Log"
{
    Caption = 'EDI Report Log';
    Editable = false;
    PageType = List;
    SourceTable = "GXL EDI Report Log";
    UsageCategory = History;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Date/Time"; Rec."Date/Time")
                {
                }
                field("Order Type"; Rec."Order Type")
                {
                }
                field("Order No."; Rec."Order No.")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                }
                field("Report Type"; Rec."Report Type")
                {
                }
                field("Attachment File Name"; Rec."Attachment File Name")
                {
                }
                field("Email Sent"; Rec."Email Sent")
                {
                }
                field("Email Sent to Vendor"; Rec."Email Sent to Vendor")
                {
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Open Attachment")
            {
                Caption = 'Open Attachment';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ShowAttachment(TRUE);
                end;
            }
            action("Save Attachment")
            {
                Caption = 'Save Attachment';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ShowAttachment(FALSE);
                end;
            }
            action("Open Order Card")
            {
                Caption = 'Open Order Card';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.OpenNavDocument();
                end;
            }
            action("Open Document Card")
            {
                Caption = 'Open Document Card';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.OpenNavStagingDocument();
                end;
            }
        }
    }
}

