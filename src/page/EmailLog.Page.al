page 50369 "GXL Email Log"
{
    Caption = 'Email Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = History;
    ApplicationArea = All;
    SourceTable = "GXL Email Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Document Type"; Rec."Document Type")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("User ID"; Rec."User ID")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Document File Type"; Rec."Document File Type")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Document Filename"; Rec."Document Filename")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field(Status; Rec.Status)
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field(GetErrorMessage; Rec.GetErrorMessage())
                {
                    Caption = 'Error Message';
                    Style = Attention;
                    StyleExpr = IsError;

                    trigger OnAssistEdit()
                    begin
                        Rec.ShowErrorMessage();
                    end;
                }
                field(Type; Rec.Type)
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Code"; Rec.Code)
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Sending Behaviour"; Rec."Sending Behaviour")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Email Type"; Rec."Email Type")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
                field("Email ID"; Rec."Email ID")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                    Visible = false;
                }
                field("Email Sent To"; Rec."Email Sent To")
                {
                    Style = Attention;
                    StyleExpr = IsError;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Open Attached Document")
            {
                Caption = 'Open Attached Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ShowDocument(TRUE);
                end;
            }
            action("Save Attached Document")
            {
                Caption = 'Save Attached Document';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ShowDocument(FALSE);
                end;
            }
            action("Open Document Card")
            {
                Caption = 'Open Document Card';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.OpenNavDocument()
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsError := Rec.Status = Rec.Status::Error;
    end;

    var
        [InDataSet]
        IsError: Boolean;
}

