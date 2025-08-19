//WMSVD-002-Boomi API Sales Order integration.
xmlport 50006 "GXL WH Sales Order"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = true;

    schema
    {
        textelement(SalesOrder)
        {
            tableelement("WH Message Lines"; "GXL WH Message Lines")
            {
                AutoReplace = false;
                AutoSave = true;
                AutoUpdate = true;
                XmlName = 'SalesLine';
                fieldelement(DocNo; "WH Message Lines"."Document No.")
                {
                    trigger OnAfterAssignField()
                    begin
                        AssignAddtionalFields();
                    end;
                }
                fieldelement(LineNo; "WH Message Lines"."Line No.")
                {
                }
                fieldelement(ILC; "WH Message Lines"."Item No.")
                {
                }
                fieldelement(QuantityToShip; "WH Message Lines"."Qty. To Receive")
                {
                }
                fieldelement(Variance; "WH Message Lines"."Qty. Variance")
                {
                }
                fieldelement(UserName; "WH Message Lines"."User Name")
                {
                }
                fieldelement(CustomerNo; "WH Message Lines"."Source No.")
                {
                }
                trigger OnBeforeInsertRecord()
                begin
                end;

                trigger OnBeforeModifyRecord()
                begin
                end;
            }
        }
    }
    var
        GlobalLocationCode: Code[10];

    local procedure AssignAddtionalFields()
    begin
        "WH Message Lines"."Import Type" := "WH Message Lines"."Import Type"::"Sales Order";
        "WH Message Lines"."Date Imported" := Today();
        "WH Message Lines"."Time Imported" := Time();
        "WH Message Lines"."Location Code" := GlobalLocationCode;
        "WH Message Lines"."Error Description" := '';
        "WH Message Lines"."Error Found" := false;
    end;

    procedure SetLocation(LocationCode: Code[10])
    begin
        GlobalLocationCode := LocationCode;
    end;
}

