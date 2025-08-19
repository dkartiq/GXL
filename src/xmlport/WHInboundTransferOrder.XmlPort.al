xmlport 50271 "GXL WH-Inbound Transfer Order"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = true;

    schema
    {
        textelement(TransferOrder)
        {
            tableelement("WH Message Lines"; "GXL WH Message Lines")
            {
                AutoReplace = false;
                AutoSave = true;
                AutoUpdate = true;
                XmlName = 'TransferLine';
                fieldelement(DocNo; "WH Message Lines"."Document No.")
                {

                    trigger OnAfterAssignField()
                    var
                    begin
                    end;
                }
                fieldelement(LineNo; "WH Message Lines"."Line No.")
                {
                }
                fieldelement(ILC; "WH Message Lines"."Item No.")
                {

                    trigger OnAfterAssignField()
                    begin
                        "WH Message Lines"."Import Type" := "WH Message Lines"."Import Type"::"Transfer Order";
                        "WH Message Lines"."Date Imported" := Today();
                        "WH Message Lines"."Time Imported" := Time();
                        "WH Message Lines"."Error Description" := '';
                        "WH Message Lines"."Error Found" := false;
                    end;
                }
                fieldelement(QuantityToReceive; "WH Message Lines"."Qty. To Receive")
                {
                }
                fieldelement(Variance; "WH Message Lines"."Qty. Variance")
                {
                }
                fieldelement(ReasonCode; "WH Message Lines"."Reason Code")
                {
                }

                trigger OnAfterInsertRecord()
                begin
                    "WH Message Lines"."Import Type" := "WH Message Lines"."Import Type"::"Transfer Order";
                end;
            }
        }
    }

}

