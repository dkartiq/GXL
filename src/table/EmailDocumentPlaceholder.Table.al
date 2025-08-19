table 50374 "GXL Email Document Placeholder"
{

    Caption = 'Email Document Placeholder';

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Customer Statement,Purchase Quote,Purchase Order,Purchase Blanket Order,Purchase Return Order,Purchase Return Shipment,Purchase CR/Adj Note,Sales Quote,Sales Order,Sales Blanket Order,Sales Shipment,Sales Invoice,Sales Return Order,Sales CR/Adj Note,Service Order,Service Shipment,Service Invoice,Service CR/Adj Note';
            OptionMembers = "Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note";

            trigger OnValidate()
            begin
                CASE "Document Type" OF

                    "Document Type"::"Customer Statement":
                        "Table No." := 18;

                    "Document Type"::"Purchase Quote":
                        "Table No." := 38;

                    "Document Type"::"Purchase Order":
                        "Table No." := 38;

                    "Document Type"::"Purchase Blanket Order":
                        "Table No." := 38;

                    "Document Type"::"Purchase Return Order":
                        "Table No." := 38;

                    "Document Type"::"Purchase Return Shipment":
                        "Table No." := 6650;

                    "Document Type"::"Purchase CR/Adj Note":
                        "Table No." := 124;

                    "Document Type"::"Sales Quote":
                        "Table No." := 36;

                    "Document Type"::"Sales Order":
                        "Table No." := 36;

                    "Document Type"::"Sales Blanket Order":
                        "Table No." := 36;

                    "Document Type"::"Sales Shipment":
                        "Table No." := 110;

                    "Document Type"::"Sales Invoice":
                        "Table No." := 112;

                    "Document Type"::"Sales Return Order":
                        "Table No." := 36;

                    "Document Type"::"Sales CR/Adj Note":
                        "Table No." := 114;

                    "Document Type"::"Service Order":
                        "Table No." := 5900;

                    "Document Type"::"Service Shipment":
                        "Table No." := 5990;

                    "Document Type"::"Service Invoice":
                        "Table No." := 5992;

                    "Document Type"::"Service CR/Adj Note":
                        "Table No." := 5994;

                END;

                IF (xRec."Document Type" <> "Document Type") THEN
                    "Field No." := 0;
            end;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            Editable = false;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'FieldRec No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."), Class = FILTER(Normal | FlowField));

            trigger OnLookup()
            begin
                FieldLookup();
            end;
        }
        field(4; "Field Caption"; Text[100])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table No."), "No." = FIELD("Field No.")));
            Caption = 'FieldRec Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Placeholder Type"; Option)
        {
            Caption = 'Placeholder Type';
            OptionCaption = ' ,Subject,Body,Filename';
            OptionMembers = " ",Subject,Body,Filename;
        }
        field(6; "Placeholder Free Text"; Text[30])
        {
            Caption = 'Placeholder Free Text';
        }
        field(7; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        VALIDATE("Document Type");
        CheckCombination();
    end;

    trigger OnModify()
    begin
        VALIDATE("Document Type");
        CheckCombination();
    end;

    var
        Text000Txt: Label 'The selected combination of %4: %1, %5: %2, %6: %3 already exists.';

    [Scope('OnPrem')]
    procedure FieldLookup()
    var
        FieldRec: Record "Field";
        FieldsLookup: Page "Fields Lookup";
    begin
        FieldRec.SETRANGE(TableNo, "Table No.");
        FieldRec.SETFILTER(Class, '%1|%2', FieldRec.Class::Normal, FieldRec.Class::FlowField);
        FieldsLookup.SETTABLEVIEW(FieldRec);
        FieldsLookup.LOOKUPMODE := TRUE;
        FieldsLookup.EDITABLE := FALSE;

        IF FieldsLookup.RUNMODAL() = ACTION::LookupOK THEN BEGIN
            FieldsLookup.GETRECORD(FieldRec);
            "Field No." := FieldRec."No.";
            CALCFIELDS("Field Caption");
        END;
    end;

    [Scope('OnPrem')]
    procedure CheckCombination()
    var
        EmailDocumentPlaceholder: Record "GXL Email Document Placeholder";
    begin
        EmailDocumentPlaceholder.SETRANGE("Document Type", "Document Type");
        EmailDocumentPlaceholder.SETRANGE("Placeholder Type", "Placeholder Type");
        EmailDocumentPlaceholder.SETRANGE("Placeholder Free Text", "Placeholder Free Text");
        IF NOT EmailDocumentPlaceholder.ISEMPTY() THEN
            ERROR(Text000Txt, "Document Type", "Placeholder Type", "Placeholder Free Text",
                          FIELDCAPTION("Document Type"), FIELDCAPTION("Placeholder Type"), FIELDCAPTION("Placeholder Free Text"));
    end;
}

