pageextension 50403 "GXL Selection Subcodes" extends "LSC Selection Subcodes"
{
    layout
    {
        addafter("Serial/Lot No. Needed")
        {
            field("GXL Saleable"; Rec."GXL Saleable")
            {
                ApplicationArea = All;
                Caption = 'Saleable';
            }
        }
    }

}