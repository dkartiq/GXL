// 001  18.03.2024 LCB-291 code added for mapping
xmlport 50094 "GXL WH-Item Adjustments v2"
{
    Direction = Both;
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = true;

    schema
    {
        textelement(ItemAdjust)
        {
            tableelement("WH Message Lines"; "GXL WH Message Lines")
            {
                AutoSave = true;
                AutoUpdate = true;
                XmlName = 'WHItemAdjustment';
                fieldelement(PoNumberLine; "WH Message Lines"."Line No.")
                {
                }
                fieldelement(AdjType; "WH Message Lines"."Entry Type")
                {
                }

                fieldelement(ILC; "WH Message Lines"."Item No.")
                {

                    trigger OnAfterAssignField()
                    var
                    begin
                        "WH Message Lines"."Import Type" := "WH Message Lines"."Import Type"::"Item Adj.";
                        "WH Message Lines"."Date Imported" := Today();
                        "WH Message Lines"."Document No." := DocNo;
                        "WH Message Lines"."Time Imported" := Time();
                    end;
                }
                fieldelement(QuantityToAdj; "WH Message Lines"."Qty. To Receive")
                {
                }
                fieldelement(ReasonCode; "WH Message Lines"."Reason Code")
                {
                }
                fieldelement(UserName; "WH Message Lines"."User Name")
                {
                }
                fieldelement(Description; "WH Message Lines".Description)
                {
                }
                fieldelement(LocationCode; "WH Message Lines"."Location Code")
                {
                    // >> 001 
                    trigger OnAfterAssignField()
                    var
                        ReasonCodeMapping: Record "GXL 3PL Reason Code Mapping";
                    begin

                        if ReasonCodeMapping.GetBCReasonCode("WH Message Lines"."Location Code", "WH Message Lines"."Reason Code", "WH Message Lines"."BC Reason Code") then begin
                            if "WH Message Lines"."BC Reason Code" = '' then
                                "WH Message Lines"."Mapping Exists" := "WH Message Lines"."Mapping Exists"::"Exists with Blank BC Reason Code"
                            else
                                "WH Message Lines"."Mapping Exists" := "WH Message Lines"."Mapping Exists"::Exists
                        end else
                            "WH Message Lines"."Mapping Exists" := "WH Message Lines"."Mapping Exists"::"Not Exists";

                    end;
                    // << 001
                }
            }
        }
    }


    trigger OnPreXmlPort()
    begin
        IntegrationSetup.Get();
        DocNo := CreateNewDocNo();
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        gStoreCode: Code[10];
        DocNo: Code[20];

    [Scope('OnPrem')]
    procedure SetXmlFilter(StoreCode: Code[10])
    begin
        gStoreCode := StoreCode;
    end;

    [Scope('OnPrem')]
    procedure ShowNewPO(StoreCode: Code[10])
    begin
    end;

    [Scope('OnPrem')]
    procedure ShowBatchPO(StoreCode: Code[10]; BatchId: Integer)
    begin
    end;

    local procedure CreateNewDocNo() NewReferenceNo: Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        NewReferenceNo := '';
        Clear(NoSeriesMgt);
        IntegrationSetup.TestField("Default WH Stk Adj No. Series");
        NewReferenceNo := NoSeriesMgt.GetNextNo(IntegrationSetup."Default WH Stk Adj No. Series", Today(), true);
    end;
}

