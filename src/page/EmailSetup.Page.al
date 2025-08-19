page 50366 "GXL Email Setup"
{
    Caption = 'Email Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "GXL Email Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Email Type"; Rec."Email Type")
                {
                    ApplicationArea = All;
                }
                field("Allow Email Only for Rel. Doc."; Rec."Allow Email Only for Rel. Doc.")
                {
                    ApplicationArea = All;
                }
                field("Clear Log Date Formula"; Rec."Clear Log Date Formula")
                {
                    ApplicationArea = All;
                }
                field("Test Mode"; Rec."Test Mode")
                {
                    ApplicationArea = All;
                }
                field("Test Email"; Rec."Test Email")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Default Document Email Setup")
            {
                Caption = 'Default Document Email Setup';
                Image = SetupLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    DocumentEmailSetup: Page "GXL Document Email Setup";
                begin
                    DocumentEmailSetup.ShowGlobalView();
                    DocumentEmailSetup.RUN();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.RESET();
        IF NOT Rec.GET() THEN BEGIN
            Rec.INIT();
            Rec.INSERT();
        END;

        EmailFunctions.CreateBaseSetup();
    end;

    var
        EmailFunctions: Codeunit "GXL Email Functions";
}

