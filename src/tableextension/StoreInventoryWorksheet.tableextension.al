tableextension 50270 "GXL Store Inventory Worksheet" extends "LSC Store Inventory Worksheet"
{
    fields
    {
        field(50270; "GXL Open"; Boolean)
        {
            Caption = 'Open';
            FieldClass = FlowField;
            CalcFormula = - exist("LSC Batch Posting Queue" where("Store Inventory Worksheet" = field(WorksheetSeqNo), Status = filter(<> Finished)));
        }
        field(50271; "GXL StockTake Description"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'StockTake Description';
        }
        field(50272; "GXL Date Opened"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Opened';
        }
        field(50273; "GXL No. of Stock Take Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("GXL PDA StockTake Line" where("Stock-Take ID" = field(WorksheetSeqNo)));
            Caption = 'No. of Stock Take Lines';
        }
        field(50274; "GXL User ID"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'User ID';
        }

    }

}