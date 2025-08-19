page 50102 "GXL Magento Web Orders"
{
    Caption = 'Magento Web Orders';
    PageType = List;
    SourceTable = "GXL Magento Web Order";
    UsageCategory = Lists;
    ApplicationArea = All;
    RefreshOnActivate = true;
    DelayedInsert = true;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Transaction Type";
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Last Modified Date-Time"; Rec."Last Modified Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("No. of Errors"; Rec."No. of Errors")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                }
                field(SalesType; Rec."Sales Type")
                {
                    ApplicationArea = All;
                }
                field("Line Number"; Rec."Line Number")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Item Number"; Rec."Item Number")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                }
                field("Amount Tendered"; Rec."Amount Tendered")
                {
                    ApplicationArea = All;
                }
                field("Freight Charge"; Rec."Freight Charge")
                {
                    ApplicationArea = All;
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Item UoM Code"; Rec."Sales Item UoM Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("Terminal No."; Rec."Terminal No.")
                {
                    ApplicationArea = All;
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                }
                field("Last Modified by User ID"; Rec."Last Modified by User ID")
                {
                    ApplicationArea = All;
                }
                field("Manually Modified"; Rec."Manually Modified")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Id; Rec.Id)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
            }
            part(ErrorListpart; "GXL Magento WO ErrorLog Sub")
            {
                ApplicationArea = All;
                SubPageLink = "Web Order Entry No." = FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ValidateOrders)
            {
                ApplicationArea = All;
                Caption = 'Validate Orders';
                Ellipsis = true;
                Image = CheckRulesSyntax;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PostMagentoWebOrder: Codeunit "GXL Post Magento Web Orders";
                begin
                    PostMagentoWebOrder.ManualProcessWebOrders(false);
                end;
            }
            action(PostOrders)
            {
                ApplicationArea = All;
                Caption = 'Post';
                Ellipsis = true;
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ShortCutKey = 'F9';

                trigger OnAction()
                var
                    PostMagentoWebOrder: Codeunit "GXL Post Magento Web Orders";
                begin
                    PostMagentoWebOrder.ManualProcessWebOrders(true);
                end;
            }
            action(ArchiveOrders)
            {
                ApplicationArea = All;
                Caption = 'Archive Orders';
                Ellipsis = true;
                Image = Archive;

                trigger OnAction()
                var
                    MagentoWebOrder: record "GXL Magento Web Order";
                begin
                    CurrPage.SETSELECTIONFILTER(MagentoWebOrder);
                    IF MagentoWebOrder.ISEMPTY() THEN
                        EXIT;
                    IF NOT CONFIRM('Do you really want to Archive the selected %1 record(s) ?', FALSE, MagentoWebOrder.COUNT()) THEN
                        EXIT;
                    MagentoWebOrder.FINDSET(TRUE);
                    REPEAT
                        MagentoWebOrder.ArchiveAndDelete();
                    UNTIL MagentoWebOrder.NEXT() = 0;
                end;
            }
        }
        area(navigation)
        {
            action(ShowErrors)
            {
                ApplicationArea = All;
                Caption = 'Show Errors';
                Image = ErrorLog;
                RunObject = Page "GXL Magento WebOrder Error Log";
                RunPageLink = "Web Order Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Web Order Entry No.");
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

    end;

    trigger OnModifyRecord(): Boolean
    begin

    end;

    trigger OnDeleteRecord(): Boolean
    begin

    end;
}

