page 50087 "API Message Log"
{
    ApplicationArea = All;
    Caption = 'API Message Log';
    PageType = List;
    SourceTable = "API Message Log";
    UsageCategory = History;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableView = sorting("Entry No.") order(descending);
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("API Type"; Rec."API Type")
                {
                }
                field("API Source"; Rec."API Source")
                {
                }
                field("API Payload"; Rec."API Payload")
                {
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Processing Start"; Rec."Processing Start")
                {
                }
                field("Processing End"; Rec."Processing End")
                {
                }
                field("Error Text"; Rec."Error Text")
                {
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Process)
            {
                Caption = 'Process';
                action("Process Selected Lines")
                {
                    Caption = 'Process Selected Lines';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Action;
                    trigger OnAction()
                    begin
                        ProcessOrReProcessRecords(true, false);
                    end;
                }
            }
            group(Attachment)
            {
                Caption = 'Attachment';
                action("Export Payload")
                {
                    Caption = 'Export Payload to File';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = ExportAttachment;
                    trigger OnAction()
                    begin
                        ExportPayload();
                    end;
                }
                action("Export Payload Base64")
                {
                    Caption = 'Export Payload to Base64';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = ExportAttachment;
                    trigger OnAction()
                    begin
                        ExportPayloadAsBase64();
                    end;
                }
            }
        }
    }

    var
        Text001: Label 'Selected records will be processed in the background. \Are you sure you want to continue?';
        Text002: Label 'Selected process will run in the background. \Log records will be updated by the background process.';
        Text003: Label 'Selected records will be processed. \Are you sure you want to continue?';
        Text004: Label 'Processing Complete.';

    local procedure ProcessOrReProcessRecords(isReProcess: Boolean; runInBackground: Boolean)
    var
        APILog: Record "API Message Log";
        APIMgt: Codeunit "API Message Log Managment";
        ConfirmationText: Text;
        CompletionText: Text;
    begin
        if runInBackground then begin
            ConfirmationText := Text001;
            CompletionText := Text002;
        end
        else begin
            ConfirmationText := Text003;
            CompletionText := Text004;
        end;

        if not Confirm(ConfirmationText, false) then
            exit;

        CurrPage.SetSelectionFilter(APILog);
        if isReProcess then
            APIMgt.ReProcessSelectedAPILogs(APILog, runInBackground)
        else
            APIMgt.ProcessSelectedAPILogs(APILog, runInBackground);
        Message(CompletionText);
    end;

    local procedure ExportPayload()
    var
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Data: BigText;
        inStm: InStream;
        outStrm: OutStream;
    begin
        Rec.CalcFields("API Payload");
        Rec.TestField("API Payload");

        FileName := 'API-Payload_' + Format(Rec."Entry No.") + '.txt';

        Data.AddText(Rec.PayloadToTextAsDecoded());
        TempBLOB.CreateOutStream(outStrm);
        Data.Write(outStrm);
        TempBLOB.CreateInStream(inStm);

        DownloadFromStream(inStm, '', '', '', FileName);
    end;

    local procedure ExportPayloadAsBase64()
    var
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Data: BigText;
        inStm: InStream;
        outStrm: OutStream;
    begin
        Rec.CalcFields("API Payload");
        Rec.TestField("API Payload");

        FileName := 'API-Payload_' + Format(Rec."Entry No.") + '.txt';

        Data.AddText(Rec.PayloadToTextAsBase64());
        TempBLOB.CreateOutStream(outStrm);
        Data.Write(outStrm);
        TempBLOB.CreateInStream(inStm);

        DownloadFromStream(inStm, '', '', '', FileName);
    end;
}
