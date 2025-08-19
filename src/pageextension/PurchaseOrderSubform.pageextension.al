// 001 BY 12.08.2025 International Purchase order Changes
pageextension 50017 "GXL Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        movefirst(Control1; Type, "No.", "Item Reference No.", Description, Quantity, "Gross Weight", "Unit of Measure", "Direct Unit Cost", "Line Amount", "Line Discount %", "Qty. to Receive", "Quantity Received", "Qty. to Invoice", "Quantity Invoiced", "Qty. to Assign", "Qty. Assigned", "Expected Receipt Date", "Order Date")
        addafter(ShortcutDimCode8)
        {
            // >> 001
            field("GXL OP Unit of Measure Code"; Rec."GXL OP Unit of Measure Code")
            {
                ApplicationArea = All;
            }
            // << 001
        }
        // >> 001
        modify("Gross Weight")
        {
            Visible = true;
            Caption = 'Gross Weight';
        }
        modify("Line Discount %")
        {
            Visible = true;
        }
        modify("Line No.")
        {
            Visible = true;
        }
        // << 001
        addafter("No.")
        {
            field("GXL Hazardous Item"; Rec."GXL Hazardous Item")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Hazardous Item field.', Comment = '%';
            }
        }
        addafter(Quantity)
        {
            field("GXL Original Ordered Quantity"; Rec."GXL Original Ordered Quantity")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Original Ordered Quantity field.', Comment = '%';
            }
            field("GXL Confirmed Quantity"; Rec."GXL Confirmed Quantity")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Confirmed Quantity field.', Comment = '%';
            }
            field("GXL Carton-Qty"; Rec."GXL Carton-Qty")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Carton-Qty. field.', Comment = '%';
            }

        }
        addafter("Gross Weight")
        {
            field("GXL Cubage"; Rec."GXL Cubage")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Cubage field.', Comment = '%';
            }
            field("Reserved Qty. (Base)"; Rec."Reserved Qty. (Base)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the reserved quantity of the item expressed in base units of measure.';
            }
        }
        addafter("Order Date")
        {

            field("GXL Order Changed Date"; Rec."GXL Order Changed Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the GXL Order Changed Date field.', Comment = '%';
            }
            field("GXL Order Changed Time"; Rec."GXL Order Changed Time")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Changed Time field.', Comment = '%';
            }
            field("GXL Order Change Reason Code"; Rec."GXL Order Change Reason Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Change Reason Code field.', Comment = '%';
            }
            field("GXL Vendor Reorder No."; Rec."GXL Vendor Reorder No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Vendor Reorder No. field.', Comment = '%';
            }
            field("GXL Changed By User ID"; Rec."GXL Changed By User ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Changed By User ID field.', Comment = '%';
            }
            field("GXL Last JDA Date Modified"; Rec."GXL Last JDA Date Modified")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the Last JDA Date Modified field.', Comment = '%';
            }
            field("GXL Primary EAN"; Rec."GXL Primary EAN")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Primary EAN field.', Comment = '%';
            }
            field("GXL OM GTIN"; Rec."GXL OM GTIN")
            {
                ToolTip = 'Specifies the value of the OM GTIN field.', Comment = '%';
            }
            field("GXL OP GTIN"; Rec."GXL OP GTIN")
            {
                ApplicationArea = All;
            }

            field("GXL Pallet GTIN"; Rec."GXL Pallet GTIN")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Pallet GTIN field.', Comment = '%';
            }
        }
        addafter(Description)
        {
            field("Item Category Description"; Rec."Item Category Description")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Item Category Description field.';
            }
        }
    }
}