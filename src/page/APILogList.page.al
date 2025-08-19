page 10016929 "GXL API Log List"
{
    PageType = List;
    SourceTable = "GXL API Log";
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;
    Caption = 'API Log List';


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("GXL Request Entry No."; Rec."GXL Request Entry No.") { }
                field("GXL Type"; Rec."GXL Type") { }
                field("GXL Partner Code"; Rec."GXL Partner Code") { }
                field("GXL System"; Rec."GXL System") { }
                field("GXL Interface Contract"; Rec."GXL Interface Contract") { }
                field("GXL Interface Contract Version"; Rec."GXL Interface Contract Version") { }
                field("GXL API Type"; Rec."GXL API Type") { }
                field("GXL Payload Type"; Rec."GXL Payload Type") { }
                field("GXL Date"; Rec."GXL Date") { }
                field("GXL Time"; Rec."GXL Time") { }
                field("GXL User"; Rec."GXL User") { }
                field("GXL Action"; Rec."GXL Action") { }
                field("GXL Function"; Rec."GXL Function") { }
                field("GXL Table No."; Rec."GXL Table No.") { }
                field("GXL Status"; Rec."GXL Status") { }
                field("GXL No. of Error Records"; Rec."GXL No. of Error Records") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Download Attachment")
            {
                Caption = 'Download Attachment';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    ApiAttachmentLogRec: Record "GXL API Attachment Log";
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    Outstr: OutStream;
                    FileName: Text;
                begin
                    // if not Rec.FindFirst() then
                    //     exit;

                    ApiAttachmentLogRec.SetRange("GXL API Log Entry No.", Rec."Entry No.");
                    if ApiAttachmentLogRec.FindFirst() then begin
                        TempBlob.CreateOutStream(Outstr);
                        ApiAttachmentLogRec."GXL Attachment".ExportStream(Outstr);
                        TempBlob.CreateInStream(InStr);
                        FileName := StrSubstNo('APIAttachment_%1.json', Rec."Entry No.");
                        DownloadFromStream(InStr, '', '', '', FileName);
                    end else
                        Message('No attachment found for this entry.');
                end;
            }
            action("Download PayLoad Attachment")
            {
                Caption = 'Download PayLoad Attachment';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    ApiAttachmentLogRec: Record "GXL API Attachment Log";
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    Outstr: OutStream;
                    FileName: Text;
                begin
                    // if not Rec.FindFirst() then
                    //     exit;

                    ApiAttachmentLogRec.SetRange("GXL API Log Entry No.", Rec."Entry No.");
                    if ApiAttachmentLogRec.FindFirst() then begin
                        TempBlob.CreateOutStream(Outstr);
                        ApiAttachmentLogRec."GXL Payload Attachment".ExportStream(Outstr);
                        TempBlob.CreateInStream(InStr);
                        FileName := StrSubstNo('PayLoadAttachment_%1.json', Rec."Entry No.");
                        DownloadFromStream(InStr, '', '', '', FileName);
                    end else
                        Message('No attachment found for this entry.');
                end;
            }
            action("View API Payload Records")
            {
                Caption = 'View API Payload Records';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    APIPayloadRequest: Record "GXL Payload Request Records";
                begin
                    APIPayloadRequest.SetRange("GXL API Log Entry No.", Rec."Entry No.");
                    Page.Run(Page::"GXL API Payload RequestRecords", APIPayloadRequest);
                end;
            }

            action("View API Data")
            {
                Caption = 'View API Data';
                Image = ViewCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    APIData: Record "GXL API Data";
                begin
                    APIData.SetRange("GXL API Log Entry No.", Rec."Entry No.");
                    Page.Run(Page::"GXL API Data List", APIData);
                end;
            }
            action("View API Matrix")
            {
                Caption = 'View API Matrix';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    PayloadData: Record "GXL Payload Request Records";
                begin
                    PayloadData.SetRange("GXL API Log Entry No.", Rec."Entry No.");
                    Page.Run(Page::"API Payload Request Matrix", PayloadData);
                end;
            }
        }
    }
}