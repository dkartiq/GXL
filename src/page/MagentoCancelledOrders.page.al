/// <summary>
/// PS-2423 Magento web order cancelled
/// </summary>
page 50045 "GXL Magento Cancelled Orders"
{
    Caption = 'Magento Cancelled Orders';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Magento Cancelled Order";
    DelayedInsert = true;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Magento WebOrder Trans. ID"; Rec."Magento WebOrder Trans. ID")
                {
                    ApplicationArea = All;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                Caption = 'Cancel Magento Web Orders';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    MagentoCancelOrdProcess: Codeunit "GXL MagentoCancelOrder-Process";
                begin
                    MagentoCancelOrdProcess.Run();
                end;
            }
        }
    }
}