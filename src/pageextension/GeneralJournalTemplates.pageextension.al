pageextension 50044 "GXL General Journal Templates" extends "General Journal Templates"
{
    layout
    {
        addlast(Control1)
        {
            //ERP-162 GL Balance by Entity Code (Dim1) +
            field("GXL Force Dim 1 Balance"; Rec."GXL Force Dim 1 Balance")
            {
                ApplicationArea = All;
            }
            //ERP-162 GL Balance by Entity Code (Dim1) +        
        }
    }

}