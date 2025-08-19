page 50356 "GXL PO Responses"
{
    Caption = 'PO Responses';
    ApplicationArea = All;
    UsageCategory = Lists;
    PageType = List;
    SourceTable = "GXL PO Response Header";
    CardPageID = "GXL PO Response";
    DataCaptionFields = "Response Number";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Response Number"; Rec."Response Number")
                {
                }
                field("PO Response Date"; Rec."PO Response Date")
                {
                }
                field("Original EDI Document No."; Rec."Original EDI Document No.")
                {
                }
                field("NAV EDI Document No."; Rec."NAV EDI Document No.")
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
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Show PO Response")
                {
                    Caption = 'Show PO Response';
                    Image = ViewOrder;
                    RunObject = Page "GXL PO Response";
                    RunPageLink = "Response Number" = FIELD("Response Number");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
    }
}

