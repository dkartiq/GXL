page 50030 "GXL NAV Cancelled Orders"
{
    /*Change Log
        PS-2270: Sync NAV cancelled orders from NAV13 over
    */

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL NAV Cancelled Order";
    SourceTableView = sorting("Replication Counter") order(descending);
    Caption = 'NAV Cancelled Orders';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Process Status"; Rec."Process Status")
                {
                    ApplicationArea = All;
                }
                field("Processed Date Time"; Rec."Processed Date Time")
                {
                    ApplicationArea = All;
                }
                field("Creation Date Time"; Rec."Creation Date Time")
                {
                    ApplicationArea = All;
                }
                field("Created By User"; Rec."Created By User")
                {
                    ApplicationArea = All;
                }
                field("Replication Counter"; Rec."Replication Counter")
                {
                    ApplicationArea = All;
                }
                // >> LCB-289
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        ShowError();
                    end;
                }
                // << LCB-289
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResetError)
            {
                ApplicationArea = All;
                Caption = 'Reset Error';
                Image = ResetStatus;

                trigger OnAction()
                begin
                    Rec.ResetError();
                    CurrPage.Update(true);
                end;
            }
            // >> LCB-289
            action(ShowErrorMessage)
            {
                ApplicationArea = All;
                Caption = 'Show Error';
                Image = Error;
                trigger OnAction()
                begin
                    ShowError();
                end;
            }
            // << LCB-289
        }
    }
    local procedure ShowError()
    begin
        if Rec."Error Message" > '' then
            Message(Rec."Error Message");
    end;
}