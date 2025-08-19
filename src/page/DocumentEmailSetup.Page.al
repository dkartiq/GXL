page 50368 "GXL Document Email Setup"
{
    Caption = 'Document Email Setup';
    ApplicationArea = All;
    PageType = List;
    SourceTable = "GXL Document Email Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document Filename"; Rec."Document Filename")
                {
                }
                field("Document File Type"; Rec."Document File Type")
                {
                }
                field("Sending Behaviour"; Rec."Sending Behaviour")
                {
                }
                field("Email From / To"; Rec."Email From / To")
                {
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Email Template")
            {
                Caption = 'Email Template';
                Image = Template;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "GXL Email Template";
                RunPageMode = Edit;
                RunPageOnRec = true;
            }
            action("Document Placeholder")
            {
                Caption = 'Document Placeholder';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "GXL Email Document Placeholder";
                RunPageLink = "Document Type" = FIELD("Document Type");
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FILTERGROUP(2);
        IF EnableGlobalView THEN
            Rec.SETRANGE("User ID", '')
        ELSE
            Rec.SETRANGE("User ID", Rec."User ID");
        Rec.FILTERGROUP(0);
    end;

    var
        [InDataSet]
        EnableGlobalView: Boolean;

    [Scope('OnPrem')]
    procedure ShowGlobalView()
    begin
        EnableGlobalView := TRUE;
    end;
}

