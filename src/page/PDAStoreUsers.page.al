page 50250 "GXL PDA-Store Users"
{
    Caption = 'PDA-Store Users';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PDA-Store User";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Store Name");
                    end;
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                }
                field(Default; Rec.Default)
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
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
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