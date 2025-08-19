page 50367 "GXL Email Template"
{
    Caption = 'Email Template';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "GXL Document Email Setup";
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control1101244006)
                {
                    ShowCaption = false;
                    group(Subject)
                    {
                        Caption = 'Subject';
                        field("Email Subject"; Rec."Email Subject")
                        {
                            ShowCaption = false;
                        }
                    }
                    group(Body)
                    {
                        Caption = 'Body';
                        field(EmailBodyTemplateCtrl; EmailBodyTemplate)
                        {
                            Caption = 'Boby';
                            ShowCaption = false;
                            MultiLine = true;

                            trigger OnValidate()
                            begin
                                Rec.SetEmailBodyTemplate(EmailBodyTemplate);
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show HTML")
            {
                Caption = 'Show HTML';
                Image = ShowMatrix;

                trigger OnAction()
                begin
                    MESSAGE(Rec.GetEmailBodytHTML());
                end;
            }
            action("Show XAML")
            {
                Caption = 'Show XAML';
                Image = XMLFile;

                trigger OnAction()
                begin
                    MESSAGE(Rec.GetEmailBody());
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EmailBodyTemplate := Rec.GetEmailBodyTemplate();
    end;

    var
        EmailBodyTemplate: Text;
}

