page 50357 "GXL PO Response"
{
    Caption = 'PO Response';
    ApplicationArea = All;
    PageType = Document;
    UsageCategory = Documents;
    SourceTable = "GXL PO Response Header";
    RefreshOnActivate = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Response Number"; Rec."Response Number")
                {
                }
                field("PO Response Date"; Rec."PO Response Date")
                {
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field("Order No."; Rec."Order No.")
                {
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                }
                field("Response Type"; Rec."Response Type")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                }
                field("Original EDI Document No."; Rec."Original EDI Document No.")
                {
                }
                field("NAV EDI Document No."; Rec."NAV EDI Document No.")
                {
                }
            }
            part(Lines; "GXL PO Response Subform")
            {
                Caption = 'Lines';
                SubPageLink = "PO Response Number" = FIELD("Response Number");
            }
        }
        area(factboxes)
        {
            systempart(Control50013; Notes)
            {
            }
            systempart(Control50014; Links)
            {
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("EDI File Log")
            {
                Caption = 'EDI File Log';
                Image = Log;
                RunObject = Page "GXL EDI File Log";
                RunPageLink = "Entry No." = FIELD("EDI File Log Entry No.");
                RunPageView = SORTING("Entry No.");
            }
            action("EDI Document Log")
            {
                Caption = 'EDI Document Log';
                Image = Log;
                RunObject = Page "GXL EDI Document Log";
                RunPageLink = "EDI File Log Entry No." = FIELD("EDI File Log Entry No.");
                RunPageMode = View;
                RunPageView = SORTING("Entry No.");
            }
        }
    }
}

