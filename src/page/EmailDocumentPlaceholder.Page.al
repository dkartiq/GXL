page 50372 "GXL Email Document Placeholder"
{
    Caption = 'Email Document Placeholder';
    ApplicationArea = All;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "GXL Email Document Placeholder";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                }
                field("Field No."; Rec."Field No.")
                {
                }
                field("Field Caption"; Rec."Field Caption")
                {
                }
                field("Placeholder Type"; Rec."Placeholder Type")
                {
                }
                field("Placeholder Free Text"; Rec."Placeholder Free Text")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.VALIDATE("Document Type", DocumentType);
    end;

    trigger OnOpenPage()
    begin
        EVALUATE(Rec."Document Type", Rec.GETFILTER("Document Type"));
        DocumentType := Rec."Document Type";
    end;

    var
        DocumentType: Integer;
}

