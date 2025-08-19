report 50354 "GXL GTIN Notification"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/GTINNotification.rdlc';
    Caption = 'GTIN Notification';
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            column(CompanyName; CompanyName())
            {
            }
            column(DocumentType_ItemSupplierGTINBuffer; FORMAT(TempItemSupplierGTINBuffer."Document Type"))
            {
            }
            column(DocumentNo_ItemSupplierGTINBuffer; TempItemSupplierGTINBuffer."Document No.")
            {
            }
            column(LineNo_ItemSupplierGTINBuffer; TempItemSupplierGTINBuffer."Line No.")
            {
            }
            column(OldGTIN_ItemSupplierGTINBuffer; TempItemSupplierGTINBuffer."Old GTIN")
            {
            }
            column(NewGTIN_ItemSupplierGTINBuffer; TempItemSupplierGTINBuffer."New GTIN")
            {
            }
            column(Change_ItemSupplierGTINBuffer; FORMAT(TempItemSupplierGTINBuffer.Change))
            {
            }

            trigger OnAfterGetRecord()
            begin
                IF Number = 1 THEN
                    TempItemSupplierGTINBuffer.FindSet()
                ELSE
                    TempItemSupplierGTINBuffer.Next();
            end;

            trigger OnPreDataItem()
            var
                RecordCount: Integer;
            begin
                TempItemSupplierGTINBuffer.Reset();
                RecordCount := TempItemSupplierGTINBuffer.Count();

                IF RecordCount = 0 THEN
                    CurrReport.Quit();

                Integer.SETRANGE(Number, 1, RecordCount);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        TempItemSupplierGTINBuffer.Reset();
        TempItemSupplierGTINBuffer.DeleteAll();
    end;

    var
        TempItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary;


    [Scope('OnPrem')]
    procedure SetGTINBuffer(var TempItemSupplierGTINBufferNew: Record "GXL Item-Supplier-GTIN Buffer" temporary)
    begin
        TempItemSupplierGTINBuffer.Reset();
        TempItemSupplierGTINBuffer.DeleteAll();

        IF TempItemSupplierGTINBufferNew.FindSet() THEN
            REPEAT
                TempItemSupplierGTINBuffer := TempItemSupplierGTINBufferNew;
                TempItemSupplierGTINBuffer.Insert();
            UNTIL TempItemSupplierGTINBufferNew.Next() = 0;
    end;
}

