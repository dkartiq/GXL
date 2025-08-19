pageextension 50018 "GXL Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Shipping)
        {
            group("GXL GXLWMS3PLGroup")
            {
                Caption = 'WMS/3PL';
                field("GXL Email To"; Rec."GXL Email To")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}