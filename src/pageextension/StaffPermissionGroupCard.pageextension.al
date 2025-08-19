pageextension 50400 "GXL Staff PermissionGroup Card" extends "LSC STAFF PER Group Card"
{
    layout
    {
        addafter("Tender Declaration")
        {
            field("GXL Post Tender Declaration"; Rec."GXL Post Tender Declaration")
            { ApplicationArea = All; }
        }
    }

}