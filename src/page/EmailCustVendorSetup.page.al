page 50371 "GXL Email Cust. & Vendor Setup"
{
    Caption = 'Email Customer & Vendor Setup';
    ApplicationArea = All;
    AutoSplitKey = true;
    PageType = List;
    SourceTable = "GXL Email Cust. & Vendor Setup";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                }
                field(Email; Rec.Email)
                {
                }
            }
        }
    }

    actions
    {
    }
}

