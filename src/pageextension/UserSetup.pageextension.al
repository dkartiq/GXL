pageextension 50001 "GXL User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("GXL Email Type"; Rec."GXL Email Type")
            {
                ApplicationArea = All;
            }
        }
    }
}