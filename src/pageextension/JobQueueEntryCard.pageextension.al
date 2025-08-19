pageextension 50351 "GXL Job Queue Entry Card" extends "Job Queue Entry Card"
{
    layout
    {
        addlast(General)
        {
            field("GXL Error Notif. Email Address"; Rec."GXL Error Notif. Email Address")
            {
                ApplicationArea = All;
            }
        }
    }

}