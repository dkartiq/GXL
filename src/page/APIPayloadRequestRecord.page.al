page 10016927 "GXL API Payload RequestRecords"
{
    PageType = List;
    SourceTable = "GXL Payload Request Records";
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    Caption = 'API Payload Request Records';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("GXL API Log Entry No."; Rec."GXL API Log Entry No.") { }
                field("GXL RecordID"; Rec."GXL RecordID") { }
                field("GXL Status"; Rec."GXL Status") { }
                field("GXL Error Desc"; Rec."GXL Error Desc") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("View API Data")
            {
                Caption = 'View API Data';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    APIData: Record "GXL API Data";
                begin
                    APIData.SetRange("GXL API PayloadRequestEntryNo.", Rec."Entry No.");
                    Page.Run(Page::"GXL API Data List", APIData);
                end;
            }
        }
    }
}