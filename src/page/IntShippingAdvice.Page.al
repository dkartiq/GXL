// >> LCB-237 <<
page 50048 "GXL Int. Shipping Advice"
{
    Caption = 'International Shipping Advice';
    PageType = Card;
    SourceTable = "GXL Intl. Shipping Advice Head";
    UsageCategory = None;
    Editable = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status';
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order No.';
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buy-from Vendor No.';
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Shipment No.';
                }
                field("Order Shipping Status"; Rec."Order Shipping Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Shipping Status';
                }
                field("Date Received"; Rec."Date Received")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Received';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code';
                }
                field("Departure Port"; Rec."Departure Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Departure Port';
                }
                field("Vessel Name"; Rec."Vessel Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vessel Name';
                }
                field("Container No."; Rec."Container No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Container No.';
                }
                field("Container Type"; Rec."Container Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Container Type';
                }
                field("Container Carrier"; Rec."Container Carrier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Container Carrier';
                }
                field("CFS Receipt Date"; Rec."CFS Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CFS Receipt Date';
                }
                field("Shipping Date"; Rec."Shipping Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Date';
                }
                field("Arrival Date"; Rec."Arrival Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Arrival Date';
                }
                field("Freight Forwarding Agent Code"; Rec."Freight Forwarding Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Freight Forwarding Agent Code';
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EDI File Log Entry No.';
                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Order No.';
                    Importance = Additional;
                }
                field("Delivery Mode"; Rec."Delivery Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Mode';
                    Importance = Additional;
                }
                field("NAV EDI File Log Entry No."; Rec."NAV EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NAV EDI File Log Entry No.';
                    Importance = Additional;
                }
            }
            part("Intl. Shipping Advice Subform"; "GXL Intl. Ship. Advice Subform")
            {
                SubPageLink = "Shipping Advice No." = field("No.");
            }
        }
    }
}
