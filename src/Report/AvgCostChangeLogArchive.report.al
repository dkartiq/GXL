//CR029: Average Cost trapping
report 50013 "GXL AvgCostChangeLog-Archive"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Average Cost Change Log - Archive';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(ArchiveBeforeCtrl; ArchiveBefore)
                    {
                        ApplicationArea = All;
                        Caption = 'Archive Before (Months)';
                        ShowMandatory = true;
                    }
                    field(ArchiveOptionCtrl; ArchiveOption)
                    {
                        ApplicationArea = All;
                        Caption = 'Archive Options';
                        OptionCaption = 'Delete,Archive,Delete/Archive';

                        trigger OnValidate()
                        begin
                            if ArchiveOption = ArchiveOption::Delete then
                                ClientFileName := '';
                            SetFileNameEditable();
                        end;
                    }
                    field(ArchiveFileNameCtrl; ClientFileName)
                    {
                        ApplicationArea = All;
                        Caption = 'Archive File Name';
                        Editable = ArchiveFileNameEditable;

                        trigger OnAssistEdit()
                        var
                            FileMgmt: Codeunit "File Management";
                        begin
                            // >> Upgrade
                            //Refer report 28166 
                            // if not FileMgt.IsWebClient() then
                            //     ClientFileName := FileMgt.SaveFileDialog('Export to CSV file', ClientFileName, FileMgt.GetToFilterText('', '.csv'))
                            // else
                            //     Error('Enter a file name');
                            FileMgmt.GetFileName(ClientFileName);
                            // << Upgrad
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if SupplyChainSetup.Get() then
                ArchiveBefore := SupplyChainSetup."AvgCostLog Archive Before";
            if ArchiveBefore = 0 then
                ArchiveBefore := 3;
            SetFileNameEditable();
        end;
    }

    trigger OnPreReport()
    begin
        if ArchiveBefore = 0 then
            Error('You must enter Archive Before (Months)');

        Evaluate(DF, StrSubstNo('-%1M', ArchiveBefore));
        ArchiveToDate := CalcDate(DF, Today());
        SetAvgCostChangeLogFilter();
        if AvgCostChangeLog.IsEmpty() then
            Error('There is no entries before %1 to be deleted/archived', ArchiveToDate);

        case ArchiveOption of
            ArchiveOption::"Delete/Archive",
            ArchiveOption::Archive:
                begin
                    if ClientFileName = '' then
                        Error('Please specify the file name');
                    ExportFile();
                end;
        end;
        case ArchiveOption of
            ArchiveOption::Delete,
            ArchiveOption::"Delete/Archive":
                DeleteAvgCostChangeLog();
        end;
    end;

    var
        SupplyChainSetup: Record "GXL Supply Chain Setup";
        AvgCostChangeLog: Record "GXL Average Cost Change Log";
        FileMgt: Codeunit "File Management";
        DF: DateFormula;
        ArchiveBefore: Integer;
        ArchiveOption: Option "Delete","Archive","Delete/Archive";
        ArchiveToDate: Date;
        ClientFileName: Text;
        ArchiveFileNameEditable: Boolean;


    local procedure SetFileNameEditable()
    begin
        if ArchiveOption = ArchiveOption::Delete then
            ArchiveFileNameEditable := false
        else
            ArchiveFileNameEditable := true;
    end;

    local procedure DeleteAvgCostChangeLog()
    begin
        AvgCostChangeLog.LockTable();
        SetAvgCostChangeLogFilter();
        if not AvgCostChangeLog.IsEmpty() then
            AvgCostChangeLog.DeleteAll();
    end;

    local procedure SetAvgCostChangeLogFilter()
    begin
        AvgCostChangeLog.Reset();
        AvgCostChangeLog.SetCurrentKey("Run Date");
        AvgCostChangeLog.SetRange("Run Date", 0D, ArchiveToDate);
    end;

    local procedure ExportFile()
    var
        AvgCostChangeLogExport: XmlPort "GXL AvgCostChangeLog-Export";
        ServerFileName: Text;
        OutS: OutStream;
        OutputFile: File;
    begin
        ServerFileName := FileMgt.ServerTempFileName('csv');

        OutputFile.TextMode(true);
        OutputFile.WriteMode(true);
        OutputFile.Create(ServerFileName, TextEncoding::UTF8);
        OutputFile.CreateOutStream(OutS);

        SetAvgCostChangeLogFilter();
        AvgCostChangeLogExport.SetTableView(AvgCostChangeLog);
        AvgCostChangeLogExport.SetDestination(OutS);
        AvgCostChangeLogExport.Export();

        OutputFile.Close();

        //if FileMgt.IsWebClient() then begin // >> Upgrade <<
        if FileMgt.GetExtension(ClientFileName) = '' then
            ClientFileName := ClientFileName + '.csv';
        FileMgt.DownloadHandler(ServerFileName, '', '', '', ClientFileName);
        // >> Upgrade
        // end else
        //     FileMgt.DownloadToFile(ServerFileName, ClientFileName);
        // << Upgrade
    end;
}