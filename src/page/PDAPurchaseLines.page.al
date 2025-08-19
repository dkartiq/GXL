page 50385 "GXL PDA-Purchase Lines"
{
    PageType = List;
    SourceTable = "GXL PDA-Purchase Lines";
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'PDA-Purchase Lines';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(content)
        {
            repeater(RepeaterGroup)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(QtyOrdered; Rec.QtyOrdered)
                {
                    ApplicationArea = All;
                }
                field(QtyToReceive; Rec.QtyToReceive)
                {
                    ApplicationArea = All;
                }
                field(InvoiceQuantity; Rec.InvoiceQuantity)
                {
                    ApplicationArea = All;
                }
                field(ReasonCode; Rec.ReasonCode)
                {
                    ApplicationArea = All;
                }
                //PS-2046+
                field("MIM User ID"; Rec."MIM User ID")
                {
                    ApplicationArea = All;
                }
                //PS-2046-
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportWHInboundPO)
            {
                Caption = 'Test Import WH Inbound PO';
                Image = TestFile;
                RunObject = xmlport "GXL WH-Inbound Purchase Order";
            }
        }
    }
}

