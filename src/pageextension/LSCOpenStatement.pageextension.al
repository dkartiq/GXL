// 001 04.03.2024 KDU HP-2249 Adjusting the decimal points.
pageextension 50354 "LSC Open Statement List" extends "LSC Open Statement List"
{
    layout
    {
        modify("VAT Amount")
        {
            Visible = false;
        }
        addafter("Posting Date")
        {
            field("GST Amount Var"; GSTAmount)
            {
                Caption = 'GST Amount';
                ApplicationArea = All;
                DecimalPlaces = 0 : 2;
                trigger OnDrillDown()
                var
                    TransSalesEntry: Record "LSC Trans. Sales Entry";
                begin
                    OnDrilldownTransSalesEntry(TransSalesEntry.FieldNo("VAT Amount"));
                end;
            }
        }
    }

    var
        GSTAmount: Decimal;

    trigger OnAfterGetRecord()
    begin
        GSTAmount := round(rec."VAT Amount", 0.01);
    end;

    internal procedure OnDrilldownTransSalesEntry(FldNo: Integer)
    var
        lvTransactionStatus: Record "LSC Transaction Status";
        lvTransSalesEntry: Record "LSC Trans. Sales Entry";
    begin
        lvTransactionStatus.Reset;
        lvTransactionStatus.SetCurrentKey("Statement No.", Status);
        lvTransactionStatus.SetRange("Statement No.", Rec."No.");
        lvTransSalesEntry.Reset;
        if lvTransactionStatus.Find('-') then
            repeat
                lvTransSalesEntry.SetRange("Store No.", lvTransactionStatus."Store No.");
                lvTransSalesEntry.SetRange("POS Terminal No.", lvTransactionStatus."POS Terminal No.");
                lvTransSalesEntry.SetRange("Transaction No.", lvTransactionStatus."Transaction No.");
                if lvTransSalesEntry.Find('-') then
                    repeat
                        lvTransSalesEntry.Mark := true;
                    until lvTransSalesEntry.Next = 0;
            until lvTransactionStatus.Next = 0;

        lvTransSalesEntry.SetRange("Store No.");
        lvTransSalesEntry.SetRange("POS Terminal No.");
        lvTransSalesEntry.SetRange("Transaction No.");

        lvTransSalesEntry.MarkedOnly := true;
        PAGE.RunModal(Page::"LSC Transaction Sales Entries", lvTransSalesEntry);
    end;


}