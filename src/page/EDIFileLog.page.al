page 50360 "GXL EDI File Log"
{
    Caption = 'EDI File Log';
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "GXL EDI File Log";

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
                field("Document Type"; Rec."Document Type")
                {
                }
                field("File Name"; Rec."File Name")
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
                field("Stock Adj. Claim Document Type"; Rec."Stock Adj. Claim Document Type")
                {
                }
                field("Stock Adj. Claim Order No."; Rec."Stock Adj. Claim Order No.")
                {
                }
                field("EDI Vendor Type"; Rec."EDI Vendor Type")
                {
                    Visible = false;
                }
                field("3PL ASN Sent"; Rec."3PL ASN Sent")
                {
                }
                field("3PL ASN Received"; Rec."3PL ASN Received")
                {
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
        }
        area(navigation)
        {
            action(Action50010)
            {
                Caption = 'EDI Document Log';
                Image = Log;
                RunObject = Page "GXL EDI Document Log";
                RunPageLink = "EDI File Log Entry No." = FIELD("Entry No.");
                RunPageMode = View;
                RunPageView = SORTING("Entry No.");
            }
        }
    }
}

