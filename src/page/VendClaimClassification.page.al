page 50265 "GXL Vend. Claim Classification"
{
    Caption = 'Vendor Claim Classification';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Vend. Claim Classification";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Claim Reason Code"; Rec."Claim Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Ullage Claim Classification"; Rec."Ullage Claim Classification")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Claim Description"; Rec."Claim Description")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
            systempart(RecordLinks; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
}