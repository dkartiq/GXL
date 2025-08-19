page 50370 "GXL Email Document Log"
{
    Caption = 'Email Document Log';
    ApplicationArea = All;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GXL Email Log";
    SourceTableTemporary = true;
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = StatusIndent;
                IndentationControls = Status;
                ShowAsTree = true;
                ShowCaption = false;
                field(Status; Rec.Status)
                {
                    Style = Strong;
                    StyleExpr = Emphasize;
                }
                field(GetErrorMessage; Rec.GetErrorMessage())
                {
                    Caption = 'Error Message';
                    Style = Strong;
                    StyleExpr = Emphasize;

                    trigger OnAssistEdit()
                    begin
                        Rec.ShowErrorMessage();
                    end;
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                }
                field("User ID"; Rec."User ID")
                {
                }
                field("Document Filename"; Rec."Document Filename")
                {
                }
                field(Type; Rec.Type)
                {
                }
                field("Code"; Rec.Code)
                {
                }
                field("Sending Behaviour"; Rec."Sending Behaviour")
                {
                }
                field("Email Type"; Rec."Email Type")
                {
                }
                field("Email Sent To"; Rec."Email Sent To")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Open Document")
            {
                Caption = 'Open Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ShowDocument(TRUE);
                end;
            }
            action("Save Document")
            {
                Caption = 'Save Document';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ShowDocument(FALSE);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusIndent := 0;
        IF IsExpanded(Rec) THEN
            ActualExpansionStatus := 1
        ELSE
            IF HasChildren(Rec) THEN
                ActualExpansionStatus := 0
            ELSE
                ActualExpansionStatus := 2;
        FormatLine();
    end;

    trigger OnOpenPage()
    begin
        ExpandAll();
    end;

    var
        RecIDFilter: RecordID;
        ActualExpansionStatus: Integer;
        [InDataSet]
        Emphasize: Boolean;
        [InDataSet]
        StatusIndent: Integer;

    [Scope('OnPrem')]
    procedure SetRecIDFilter(InputRecID: RecordID)
    begin
        RecIDFilter := InputRecID;
    end;

    local procedure ExpandAll()
    begin
        CopyEmailLogTemp(FALSE);
    end;

    local procedure CopyEmailLogTemp(OnlyRoot: Boolean)
    var
        EmailLog: Record "GXL Email Log";
        EmailID: Code[100];
        i: Integer;
    begin
        Rec.RESET();
        Rec.DELETEALL();

        EmailLog.SETCURRENTKEY("Created Date Time", "Record ID", "Email ID");
        EmailLog.SETAUTOCALCFIELDS("Document File");
        EmailLog.SETRANGE("Record ID", RecIDFilter);
        IF EmailLog.FINDSET() THEN
            REPEAT
                i += 1;

                IF (EmailID <> EmailLog."Email ID") THEN BEGIN
                    EmailID := EmailLog."Email ID";

                    Rec.INIT();
                    Rec."Entry No." := i;
                    Rec."Document Type" := EmailLog."Document Type";
                    Rec."Document File Type" := EmailLog."Document File Type";
                    Rec."User ID" := EmailLog."User ID";
                    Rec."Email ID" := EmailLog."Email ID";
                    Rec.Status := EmailLog.Status;
                    Rec."Error Message" := EmailLog."Error Message";
                    Rec."Error Message 2" := EmailLog."Error Message 2";
                    Rec."Error Message 3" := EmailLog."Error Message 3";
                    Rec."Error Message 4" := EmailLog."Error Message 4";
                    Rec.Type := EmailLog.Type;
                    Rec.Code := EmailLog.Code;
                    Rec."Sending Behaviour" := EmailLog."Sending Behaviour";
                    Rec."Email Type" := EmailLog."Email Type";
                    Rec."Email Sent To" := EmailLog."Email Sent To";
                    Rec.Indentation := 0;
                    Rec.INSERT();

                    i += 1;
                END;

                IF NOT OnlyRoot THEN BEGIN
                    Rec.INIT();
                    Rec := EmailLog;
                    Rec."Entry No." := i;
                    Rec.Indentation := 1;
                    Rec.INSERT();
                END;

            UNTIL EmailLog.NEXT() = 0;

        IF Rec.FINDFIRST() THEN;
    end;

    local procedure HasChildren(var ActualEmailLog: Record "GXL Email Log" temporary): Boolean
    var
        EmailLog2: Record "GXL Email Log" temporary;
    begin
        EmailLog2.COPY(ActualEmailLog, TRUE);

        IF EmailLog2.NEXT() = 0 THEN
            EXIT(FALSE);

        EXIT(EmailLog2.Indentation > ActualEmailLog.Indentation);
    end;

    local procedure IsExpanded(var ActualEmailLog: Record "GXL Email Log" temporary): Boolean
    var
        xEmailLog: Record "GXL Email Log" temporary;
        Found: Boolean;
    begin
        xEmailLog := Rec;
        Rec := ActualEmailLog;
        Found := (Rec.NEXT() <> 0);
        IF Found THEN
            Found := (Rec.Indentation > ActualEmailLog.Indentation);
        Rec := xEmailLog;
        EXIT(Found);
    end;

    local procedure FormatLine()
    begin
        StatusIndent := Rec.Indentation;
        Emphasize := StatusIndent = 0;
    end;
}

