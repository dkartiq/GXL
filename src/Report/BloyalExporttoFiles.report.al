report 50172 "GXL Bloyal Export to Files"
{
    //Test report only

    Caption = 'Bloyal Export to Files';
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
                                BloyalAzureLog.Get(EntryNo);

                                TestWebServiceName(BloyalAzureLog);
                                BloyalAzureLog.TestField(Reset, true);
                            end;
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            BloyalAzureLog.SetCurrentKey("Web Service Name");
                            BloyalAzureLog.SetRange("Web Service Name", TestOption);
                            BloyalAzureLog.SetRange(Reset, true);
                            if Page.RunModal(0, BloyalAzureLog) = Action::LookupOK then
                                EntryNo := BloyalAzureLog."Batch ID";
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
        BloyalAzureLog: Record "GXL Bloyal Azure Log";
        BLoyalSalesPayment: Codeunit "GXL Bloyal Sales & Payment";
        BloyalSOH: Codeunit "GXL Bloyal SOH";
        BloyalProduct: Codeunit "GXL Bloyal Product";
        BloyalHierarchy: Codeunit "GXL Bloyal Hierarchy";
        TestOption: enum "GXL Bloyal Web Service Name";
        EntryNo: Integer;


    trigger OnPreReport()
    var
        LastEntryNo: Integer;
        LastEndDT: DateTime;
    begin
        if not Confirm('Please note this process only export the %1 to file. Do you want to continue?', false, format(TestOption)) then
            CurrReport.Quit();

        if EntryNo <> 0 then begin
            BloyalAzureLog.Get(EntryNo);
            TestWebServiceName(BloyalAzureLog);
            BloyalAzureLog.TestField(Reset, true);

            case BloyalAzureLog."Web Service Name" of
                BloyalAzureLog."Web Service Name"::"Sales & Payment":
                    begin
                        BLoyalSalesPayment.SetBloyalAzureLog(BloyalAzureLog);
                        BLoyalSalesPayment.ProcessTransSalesPayment(BloyalAzureLog."Start Entry No.", BloyalAzureLog."End Entry No.", true, false);
                    end;

                BloyalAzureLog."Web Service Name"::SOH:
                    begin
                        BloyalSOH.SetBloyalAzureLog(BloyalAzureLog);
                        BloyalSOH.ProcessSOH(BloyalAzureLog."Start Entry No.", BloyalAzureLog."End Entry No.", true, false);
                    end;

                BloyalAzureLog."Web Service Name"::Product:
                    begin
                        BloyalProduct.SetBloyalAzureLog(BloyalAzureLog);
                        //WRP-397+
                        //BloyalProduct.ProcessProduct(BloyalAzureLog."Start Date Time Modified", BloyalAzureLog."End Date Time Modified", true, false);
                        BloyalProduct.ProcessProduct(BloyalAzureLog."Start Entry No.", BloyalAzureLog."End Entry No.", true, false);
                        //WRP-397-
                    end;

                BloyalAzureLog."Web Service Name"::Division:
                    begin
                        BloyalHierarchy.SetBloyalAzureLog(BloyalAzureLog);
                        BloyalHierarchy.ProcessDivision(BloyalAzureLog."Start Date Time Modified", BloyalAzureLog."End Date Time Modified", true, false);
                    end;

                BloyalAzureLog."Web Service Name"::"Item Category":
                    begin
                        BloyalHierarchy.SetBloyalAzureLog(BloyalAzureLog);
                        BloyalHierarchy.ProcessItemCategory(BloyalAzureLog."Start Date Time Modified", BloyalAzureLog."End Date Time Modified", true, false);
                    end;

                BloyalAzureLog."Web Service Name"::"Retail Product Group":
                    begin
                        BloyalHierarchy.SetBloyalAzureLog(BloyalAzureLog);
                        BloyalHierarchy.ProcessRetailProductGroup(BloyalAzureLog."Start Date Time Modified", BloyalAzureLog."End Date Time Modified", true, false);
                    end;

            end;

        end else begin
            GetLastProcessId(LastEntryNo, LastEndDT);
            case TestOption of
                TestOption::"Sales & Payment":
                    BLoyalSalesPayment.ProcessTransSalesPayment(LastEntryNo + 1, 0, false, false);

                TestOption::SOH:
                    BloyalSOH.ProcessSOH(LastEntryNo + 1, 0, false, false);

                TestOption::Product:
                    begin
                        if Item.GetFilters() <> '' then
                            BloyalProduct.ProcessProduct(Item, false, false)
                        //WRP-397+
                        /*
                        else begin
                            if LastEndDT <> 0DT then
                                LastEndDT := LastEndDT + 1;
                            BloyalProduct.ProcessProduct(LastEndDT, 0DT, false, false);
                        end;
                        */
                        else
                            BloyalProduct.ProcessProduct(LastEntryNo + 1, 0, false, false);
                        //WRP-397-
                    end;

                TestOption::Division:
                    begin
                        if LastEndDT <> 0DT then
                            LastEndDT := LastEndDT + 1;
                        BloyalHierarchy.ProcessDivision(LastEndDT, 0DT, false, false);
                    end;

                TestOption::"Item Category":
                    begin
                        if LastEndDT <> 0DT then
                            LastEndDT := LastEndDT + 1;
                        BloyalHierarchy.ProcessItemCategory(LastEndDT, 0DT, false, false);
                    end;

                TestOption::"Retail Product Group":
                    begin
                        if LastEndDT <> 0DT then
                            LastEndDT := LastEndDT + 1;
                        BloyalHierarchy.ProcessRetailProductGroup(LastEndDT, 0DT, false, false);
                    end;

            end;
        end;
    end;

    local procedure GetLastProcessId(var LastEntryNo: Integer; var LastEndDT: DateTime)
    begin
        case TestOption of
            TestOption::"Sales & Payment":
                LastEntryNo := BLoyalSalesPayment.GetNextEntryNo() - 1;

            TestOption::SOH:
                LastEntryNo := BloyalSOH.GetNextEntryNo() - 1;

            TestOption::Product:
                //WRP-397+
                //LastEndDT := BloyalProduct.GetLastEndDateTime();
                LastEntryNo := BloyalProduct.GetNextEntryNo() - 1;
            //WRP-397-

            TestOption::Division,
            TestOption::"Item Category",
            TestOption::"Retail Product Group":
                LastEndDT := BloyalHierarchy.GetLastEndDateTime(TestOption);
        end;

    end;

    local procedure TestWebServiceName(_BloyalAzureLog: Record "GXL Bloyal Azure Log")
    begin
        if _BloyalAzureLog."Web Service Name" <> TestOption then
            Error('%1 must be %2', _BloyalAzureLog.FieldCaption("Web Service Name"), TestOption);
    end;
}