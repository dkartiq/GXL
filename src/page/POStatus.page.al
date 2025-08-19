page 10016881 "GXL PO Status"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    PageType = List;
    SourceTable = "GXL PO Status";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Authorized Users"; Rec."Authorized Users")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authorized Users field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Possible Next Status")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "GXL PO Status Change Mapping";
                RunPageLink = From = field(Status);
            }
        }
    }
    procedure GetSelectedRecords(Var POStatus: Record "GXL PO Status")
    begin
        CurrPage.SetSelectionFilter(POStatus);
    end;
}