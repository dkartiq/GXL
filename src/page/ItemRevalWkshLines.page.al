/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
page 50042 "GXL Item Reval. Wksh. Lines"
{
    Caption = 'Item Revaluation Wksh. Lines';
    DataCaptionFields = "Batch ID";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = true;
    SourceTable = "GXL Item Reval. Wksh. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Amount;
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleTxt;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleTxt;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Unit Cost (Revalued)"; Rec."Unit Cost (Revalued)")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost (Calculated)"; Rec."Unit Cost (Calculated)")
                {
                    ApplicationArea = All;
                }
                field("Inventory Value (Revalued)"; Rec."Inventory Value (Revalued)")
                {
                    ApplicationArea = All;
                }
                field("Inventory Value (Calculated)"; Rec."Inventory Value (Calculated)")
                {
                    ApplicationArea = All;
                }
                //ERP-320 +
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Gen. Product Posting Group"; Rec."Gen. Product Posting Group")
                {
                    ApplicationArea = All;
                }
                //ERP-320 -
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        if Rec."Error Message" <> '' then
                            Message(Rec."Error Message");
                    end;
                }
                field("Processed Date Time"; Rec."Processed Date Time")
                {
                    ApplicationArea = All;
                }
                field("Processed by User"; Rec."Processed by User")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Batch ID"; Rec."Batch ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Page Item Card")
            {
                ApplicationArea = All;
                Caption = 'Item Card';
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                RunPageMode = View;
                Scope = Repeater;
                ShortCutKey = 'Shift+F7';
            }
            action("Page Item Ledger Entries")
            {
                ApplicationArea = All;
                Caption = 'Ledger Entries';
                Image = ItemLedger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Item Ledger Entries";
                RunPageLink = "Item No." = FIELD("Item No.");
                RunPageView = SORTING("Item No.");
                Scope = Repeater;
                ShortCutKey = 'Ctrl+F7';
            }
            action("Page Value Entries")
            {
                ApplicationArea = All;
                Caption = 'Value Entries';
                Image = ValueLedger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Value Entries";
                RunPageLink = "Item No." = FIELD("Item No.");
                RunPageView = SORTING("Item No.");
                Scope = Repeater;
            }
            action("Page Navigate")
            {
                ApplicationArea = All;
                Caption = 'Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run;
                end;
            }

            action(ShowWkshLocLines)
            {
                ApplicationArea = All;
                Caption = 'Worksheet Location Lines';
                Image = Line;
                RunObject = page "GXL Item Reval. Wksh Loc Lines";
                RunPageLink = "Batch ID" = field("Batch ID"), "Wksh. Line No." = field("Line No.");
                RunPageMode = View;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusStyleTxt := Rec.GetStatusStyleTxt();
    end;

    trigger OnOpenPage()
    begin
        if Rec.GetFilters() <> '' then
            if Rec.FindFirst() then;
    end;

    var
        StatusStyleTxt: Text;
}

