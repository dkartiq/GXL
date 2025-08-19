page 50007 "GXL Illegal Items"
{
    Caption = 'Illegal Items';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Illegal Item";
    DelayedInsert = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                }
                field(Legal; Rec.Legal)
                {
                    ApplicationArea = All;
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                }
                field("Last Modified User"; Rec."Last Modified User")
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
        area(Navigation)
        {
            action(IllegalProdRangLog)
            {
                Caption = 'Illegal Product Range Log';
                Image = Log;
                RunObject = page "GXL Illegal Product Range Log";
            }
        }
        area(Processing)
        {
            action(DeleteIllegalRangeLog)
            {
                Caption = 'Delete Selected';
                Image = Delete;
                trigger OnAction()
                var
                    IllegalItems: Record "GXL Illegal Item";
                    SelectedCtr: Integer;
                    Windows: Dialog;
                begin
                    CurrPage.SetSelectionFilter(IllegalItems);
                    SelectedCtr := IllegalItems.Count();
                    if SelectedCtr = 0 then
                        Error('You must select at least 1 record for deletion')
                    else begin
                        if Confirm('You have selected %1 records for deletion.\\Do you want to proceed?', false, SelectedCtr) then begin
                            Windows.Open('Deleting selected records...');
                            IllegalItems.DeleteAll();
                            Windows.Close();
                            Message('%1 records were successfully deleted', SelectedCtr);
                        end;
                    end;
                end;
            }
        }
    }
}