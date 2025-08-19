page 50008 "GXL Illegal Product Range Log"
{
    Caption = 'Illegal Product Range Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Illegal Product Range Log";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                }
                field("Logged Date"; Rec."Logged Date")
                {
                    ApplicationArea = All;
                }
                field("Sent Date"; Rec."Sent Date")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(Print)
            {
                Caption = 'Print';
                Image = PrintReport;

                trigger OnAction()
                begin
                    Report.RunModal(Report::"GXL Products Unable to Range");
                end;
            }
            action(SendEmail)
            {
                Caption = 'Send Email';
                Image = SendEmailPDF;

                trigger OnAction()
                var
                    IllegalProdRangeNotif: Codeunit "GXL Illegal Prod Range Notif.";
                begin
                    IllegalProdRangeNotif.CheckEmailSetup();
                    Report.RunModal(Report::"GXL Send Prods Unable to Range");
                end;
            }
        }
    }
}