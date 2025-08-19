tableextension 50400 "GXL Staff Permission Group" extends "LSC STAFF PER Group"
{
    fields
    {
        field(50400; "GXL Post Tender Declaration"; Option)
        {
            Caption = 'Post Tender Declaration';
            DataClassification = CustomerContent;
            OptionMembers = "No","Yes";
            OptionCaption = 'No,Yes';
        }
    }


}