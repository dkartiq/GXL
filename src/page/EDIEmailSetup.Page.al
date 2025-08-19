page 50381 "GXL EDI Email Setup"
{
    Caption = 'EDI Email Setup';
    DataCaptionFields = "Area of Emailing";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "GXL EDI Email Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group1)
            {
                field("Area of Emailing"; Rec."Area of Emailing")
                {
                }
                field("Email To"; Rec."Email To")
                {
                    ExtendedDatatype = EMail;
                }
                field("Email CC"; Rec."Email CC")
                {
                    ExtendedDatatype = EMail;
                }
                field("Email Supplier"; Rec."Email Supplier")
                {
                }
                field(Subject; Rec.Subject)
                {
                    ToolTip = 'If %1, %2, %3 is specified, it will be replaced with the Document No. of the respective record, Vendor No. & Vendor Name respectively.';
                }
                field(Body; Rec.Body)
                {
                    // >> LCB-86
                    //Editable = false;
                    // >> LCB-86
                }
            }
            // >> LCB-86
            group(Group2)
            {
                ShowCaption = false;
                fixed("Text Substitution Help...")
                {
                    group("")
                    {
                        field("Subject "; Text001) { ApplicationArea = All; }
                        field("Subject (AP Notifications Only)"; Text002) { ApplicationArea = All; }
                        field("Body "; Text003) { ApplicationArea = All; }
                    }
                }
            }
            // << LCB-86
        }
    }

    actions
    {
    }

    // >> LCB-86
    var
        Text001: Label '%1 = Source Doc. No.';
        Text002: Label '%2 = Vendor No., %3 = Vendor Name.';
        Text003: Label '%1 = Source Document Number, %2 = System Error Message, %3 = Amount relevant to the area (INV Credit Notif. only).';
    // << LCB-86        
}

