report 50480 "GXL Comestri Export to Files"
{
    //Test report only

    Caption = 'Comestri Export to Files';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(TestOptionCtrl; TestOption)
                    {
                        Caption = 'Type';

                        trigger OnValidate()
                        begin
                        end;
                    }
                    field(ResetCtrl; EntryNo)
                    {
                        Caption = 'Azure Log Entry No.';
                        ToolTip = 'Select the Azure Log Entry No. to re-process';

                        trigger OnValidate()
                        begin
                            if EntryNo <> 0 then begin
                                ComestriAzureLog.Get(EntryNo);

                                TestWebServiceName(ComestriAzureLog);
                                ComestriAzureLog.TestField(Reset, true);
                            end;
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            ComestriAzureLog.SetCurrentKey("Web Service Name");
                            ComestriAzureLog.SetRange("Web Service Name", TestOption);
                            ComestriAzureLog.SetRange(Reset, true);
                            if Page.RunModal(0, ComestriAzureLog) = Action::LookupOK then
                                EntryNo := ComestriAzureLog."Batch ID";
                        end;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
            }
        }
    }

    var
        ComestriAzureLog: Record "GXL Comestri Azure Log";
        //ComestriSalesPayment: Codeunit "GXL Comestri Sales & Payment";
        ComestriSOH: Codeunit "GXL Comestri SOH";
        ComestriProduct: Codeunit "GXL Comestri Product";
        //ComestriHierarchy: Codeunit "GXL Comestri Hierarchy";
        TestOption: Option "Product","SOH";
        EntryNo: Integer;

    trigger OnPreReport()
    var
        LastEntryNo: Integer;
        LastEndDT: DateTime;
    begin
        if not Confirm('Please note this process only export the %1 to file. Do you want to continue?', false, format(TestOption)) then
            CurrReport.Quit();

        if EntryNo <> 0 then begin
            ComestriAzureLog.Get(EntryNo);
            TestWebServiceName(ComestriAzureLog);
            ComestriAzureLog.TestField(Reset, true);

            case ComestriAzureLog."Web Service Name" of

                ComestriAzureLog."Web Service Name"::SOH:
                    begin
                        ComestriSOH.SetComestriAzureLog(ComestriAzureLog);
                        ComestriSOH.ProcessSOH(true, false, false);
                    end;

                ComestriAzureLog."Web Service Name"::Product:
                    begin
                        ComestriProduct.SetComestriAzureLog(ComestriAzureLog);
                        ComestriProduct.ProcessProduct(true, false, false);
                    end;

            end;

        end else begin
            GetLastProcessId(LastEntryNo, LastEndDT);
            case TestOption of
                TestOption::SOH:
                    ComestriSOH.ProcessSOH(false, false, false);

                TestOption::Product:
                    begin
                        if Item.GetFilters() <> '' then
                            ComestriProduct.ProcessProduct(false, false, false)
                        else begin
                            if LastEndDT <> 0DT then
                                LastEndDT := LastEndDT + 1;
                            ComestriProduct.ProcessProduct(false, false, false);
                        end;
                    end;
            end;
        end;
    end;

    local procedure GetLastProcessId(var LastEntryNo: Integer; var LastEndDT: DateTime)
    begin
        case TestOption of

            TestOption::SOH:
                LastEntryNo := ComestriSOH.GetNextEntryNo() - 1;

            TestOption::Product:
                LastEndDT := ComestriProduct.GetLastEndDateTime();

        end;

    end;

    local procedure TestWebServiceName(_ComestriAzureLog: Record "GXL Comestri Azure Log")
    begin
        if _ComestriAzureLog."Web Service Name" <> TestOption then
            Error('%1 must be %2', _ComestriAzureLog.FieldCaption("Web Service Name"), TestOption);
    end;
}