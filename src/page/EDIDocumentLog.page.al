page 50359 "GXL EDI Document Log"
{
    Caption = 'EDI Document Log';
    Editable = false;
    PageType = List;
    SourceTable = "GXL EDI Document Log";
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
                    Visible = false;
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
                field("Supplier No."; Rec."Supplier No.")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("Original Document No."; Rec."Original Document No.")
                {
                }
                field("EDI Vendor Type"; Rec."EDI Vendor Type")
                {
                    Description = 'pv00.01';
                }
                field("File Name"; Rec."File Name")
                {
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Error Code"; Rec."Error Code")
                {
                }
                field(GetErrorMessage; Rec.GetErrorMessage())
                {
                    Caption = 'Error Message';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowErrorMessage();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Error Message")
            {
                Caption = 'Show Error Message';
                Image = Error;

                trigger OnAction()
                begin
                    Rec.ShowErrorMessage();
                end;
            }
            action("View Document")
            {
                Caption = 'View Document';
                Image = Document;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.OpenDocument();
                end;
            }
        }
        area(navigation)
        {
            action(Action50018)
            {
                Caption = 'EDI File Log';
                Image = Log;
                RunObject = Page "GXL EDI File Log";
                RunPageLink = "Entry No." = FIELD("EDI File Log Entry No.");
            }
        }
    }
}

