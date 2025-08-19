pageextension 50000 "GXL Item Units of Measure" extends "Item Units of Measure"
{
    layout
    {
        addafter("Qty. per Unit of Measure")
        {
            field("GXL Legacy Item No."; Rec."GXL Legacy Item No.")
            {
                ApplicationArea = All;
            }
            field("GXL Unit Price"; Rec."GXL Unit Price")
            {
                ApplicationArea = All;
            }
            field("GXL OM Depth"; Rec."GXL OM Depth")
            {
                ApplicationArea = All;
            }
            field("GXL OM Width"; Rec."GXL OM Width")
            {
                ApplicationArea = All;
            }
            field("GXL OM Height"; Rec."GXL OM Height")
            {
                ApplicationArea = All;
            }
            field("GXL OP Depth"; Rec."GXL OP Depth")
            {
                ApplicationArea = All;
            }
            field("GXL OP Width"; Rec."GXL OP Width")
            {
                ApplicationArea = All;
            }
            field("GXL OP Height"; Rec."GXL OP Height")
            {
                ApplicationArea = All;
            }
        }
    }

}