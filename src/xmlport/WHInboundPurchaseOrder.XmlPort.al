// 001 07.10.2024 KDU LCB-258 https://petbarnjira.atlassian.net/browse/LCB-258 Reset the error if the file is processed again.
xmlport 50270 "GXL WH-Inbound Purchase Order"
{
    Direction = Both;
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = true;

    schema
    {
        textelement(Root)
        {
            tableelement("WH Message Lines"; "GXL WH Message Lines")
            {
                AutoUpdate = true;
                MinOccurs = Once;
                XmlName = 'PurchaseLines';
                fieldelement(PONumber; "WH Message Lines"."Document No.")
                {
                }
                fieldelement(LineNo; "WH Message Lines"."Line No.")
                {
                }
                fieldelement(ILC; "WH Message Lines"."Item No.")
                {

                    trigger OnAfterAssignField()
                    var
                    begin
                        "WH Message Lines"."Import Type" := "WH Message Lines"."Import Type"::"Purchase Order";
                        "WH Message Lines"."Date Imported" := Today();
                        "WH Message Lines"."Time Imported" := Time();
                    end;
                }
                fieldelement(ReceiveQty; "WH Message Lines"."Qty. To Receive")
                {
                    // >> 001
                    trigger OnAfterAssignField()
                    begin
                        "WH Message Lines"."Import Type" := "WH Message Lines"."Import Type"::"Purchase Order";
                        "WH Message Lines"."Date Imported" := Today();
                        "WH Message Lines"."Time Imported" := Time();
                        "WH Message Lines"."Error Found" := false;
                        "WH Message Lines"."Error Description" := '';
                    end;
                    // << 001
                }
                fieldelement(QtyVar; "WH Message Lines"."Qty. Variance")
                {
                }
                fieldelement(ReasonCode; "WH Message Lines"."Reason Code")
                {
                }
            }
        }
    }

}

