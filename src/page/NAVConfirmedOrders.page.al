page 50141 "GXL NAV Confirmed Orders"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL NAV Confirmed Order";
    SourceTableView = sorting("Replication Counter") order(descending);
    Caption = 'NAV Confirmed Orders';
    Editable = false;
    CardPageId = "GXL NAV Confirmed Order";
    LinksAllowed = false;

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
                //ERP-328 +
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                //ERP-328 -
                field("Process Status"; Rec."Process Status")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                // >> LCB-260
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        ShowError();
                    end;
                }
                // << LCB-260
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                }
                field("Created By User ID"; Rec."Created By User ID")
                {
                    ApplicationArea = All;
                }
                field("Replication Counter"; Rec."Replication Counter")
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
            action(ResetError)
            {
                ApplicationArea = All;
                Caption = 'Reset Error';
                Image = ResetStatus;

                trigger OnAction()
                var
                    NAVConfirmedOrder: Record "GXL NAV Confirmed Order";
                begin
                    // >> LCB-98
                    CurrPage.SetSelectionFilter(NAVConfirmedOrder);
                    if NAVConfirmedOrder.FindSet() then
                        repeat
                            if NAVConfirmedOrder."Process Status" <> NAVConfirmedOrder."Process Status"::"Creation Error" then
                                Error('Only Status = Creation Error can be reset.');

                            NAVConfirmedOrder.Validate("Process Status", NAVConfirmedOrder."Process Status"::Imported);
                            NAVConfirmedOrder.Modify();
                        until NAVConfirmedOrder.Next() = 0;
                    // ResetError();
                    // CurrPage.Update(true);
                    // << LCB-98
                end;
            }
            // >> LCB-260
            action("Show Error")
            {
                ApplicationArea = All;
                Caption = 'Show Error';
                Image = Error;
                trigger OnAction()
                begin
                    ShowError();
                end;
            }
            // << LCB-260
        }
    }
    // >> LCB-260
    local procedure ShowError()
    begin
        if Rec."Error Message" > '' then
            Message(Rec."Error Message");
    end;
    // << LCB-260
}