page 50451 "GXL Intl. Shipping Advices"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Intl. Shipping Advice Head";
    Editable = false;
    Caption = 'International Shipping Advices';
    CardPageId = "GXL Int. Shipping Advice";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Date Received"; Rec."Date Received")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = All;
                }
                field("Order Shipping Status"; Rec."Order Shipping Status")
                {
                    ApplicationArea = All;
                }
                field("Delivery Mode"; Rec."Delivery Mode")
                {
                    ApplicationArea = All;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Departure Port"; Rec."Departure Port")
                {
                    ApplicationArea = All;
                }
                field("Vessel Name"; Rec."Vessel Name")
                {
                    ApplicationArea = All;
                }
                field("Container No."; Rec."Container No.")
                {
                    ApplicationArea = All;
                }
                field("Container Type"; Rec."Container Type")
                {
                    ApplicationArea = All;
                }
                field("Container Carrier"; Rec."Container Carrier")
                {
                    ApplicationArea = All;
                }
                field("CFS Receipt Date"; Rec."CFS Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Shipping Date"; Rec."Shipping Date")
                {
                    ApplicationArea = All;
                }
                field("Arrival Date"; Rec."Arrival Date")
                {
                    ApplicationArea = All;
                }
                field("Freight Forwarding Agent Code"; Rec."Freight Forwarding Agent Code")
                {
                    ApplicationArea = All;
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                }
            }
        }

    }


}