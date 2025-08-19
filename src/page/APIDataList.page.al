page 10016926 "GXL API Data List"
{
    PageType = List;
    SourceTable = "GXL API Data";
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    Caption = 'API Data List';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("GXL API Log Entry No."; Rec."GXL API Log Entry No.") { }
                field("GXL API PayloadRequestEntryNo."; Rec."GXL API PayloadRequestEntryNo.") { }
                field("GXL Field No."; Rec."GXL Field No.") { }
                field("GXL Field Name"; Rec."GXL Field Name") { }
                field("GXL Field Value"; Rec."GXL Field Value") { }
                field("GXL Error Desc"; Rec."GXL Error Desc") { }
            }
        }
    }
}