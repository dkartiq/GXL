page 50100 "GXL Magento Web Order Entity"
{
    PageType = API;
    Caption = 'magentoWebOrders', Locked = true;
    APIVersion = 'v1.0';
    APIGroup = 'gxl';
    APIPublisher = 'gxl';
    EntityName = 'magentoWebOrder';
    EntitySetName = 'magentoWebOrders';
    ODataKeyFields = Id;
    DelayedInsert = true;
    SourceTable = "GXL Magento Web Order";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    ApplicationArea = All;
                }
                field(transactionId; Rec."Transaction ID")
                {
                    ApplicationArea = All;
                }
                field(transactionType; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }
                field(storeNo; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field(terminalNo; Rec."Terminal No.")
                {
                    ApplicationArea = All;
                }
                field(staffID; Rec."Staff ID")
                {
                    ApplicationArea = All;
                }
                field(transDate; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                }
                field(SalesType; Rec."Sales Type")
                {
                    ApplicationArea = All;
                }
                field(lineNumber; Rec."Line Number")
                {
                    ApplicationArea = All;
                }
                field(itemNumber; Rec."Item Number")
                {
                    ApplicationArea = All;
                }
                field(quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(price; Rec.Price)
                {
                    ApplicationArea = All;
                }
                field(tenderType; Rec."Tender Type")
                {
                    ApplicationArea = All;
                }
                field(amountTendered; Rec."Amount Tendered")
                {
                    ApplicationArea = All;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date-Time")
                {
                    ApplicationArea = All;
                }
                field(entryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field(freightCharge; Rec."Freight Charge")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if GuiAllowed() then
            Error('You cannot insert records using this page.');
        Rec."Entry No." := 0;
        clear(Rec.id);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            Error('Value of id is immutable.');
        if xRec."Last Modified Date-Time" <> Rec."Last Modified Date-Time" then
            Error('Value of lastModifiedDateTime is immutable.');
        if xRec."Entry No." <> Rec."Entry No." then
            Error('Value of entryNo is immutable.');
    end;

    trigger OnDeleteRecord(): Boolean
    begin

    end;
}

