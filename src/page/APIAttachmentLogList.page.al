page 10016928 "GXL API Attachment Log List"
{
    PageType = List;
    SourceTable = "GXL API Attachment Log";
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    Caption = 'API Attachment Log List';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("GXL API Log Entry No."; Rec."GXL API Log Entry No.") { }
                field("GXL Payload Attachment"; Rec."GXL Payload Attachment") { }
                field("GXL Attachment"; Rec."GXL Attachment") { }
            }
        }
    }
}