page 50380 "GXL Freight Forwarders"
{
    PageType = List;
    SourceTable = "GXL Freight Forwarder";
    Caption = 'Freight Forwarders';
    UsageCategory = Lists;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                }
                field(Name; Rec.Name)
                {
                }
                field("GXL Customer ID"; Rec."GXL Customer ID")
                {
                }
                field("Outbound FTP Folder"; Rec."Outbound FTP Folder")
                {
                }
                field("Inbound FTP Folder"; Rec."Inbound FTP Folder")
                {
                }
                field("Archive Folder"; Rec."Archive Folder")
                {
                }
                field("Error Folder"; Rec."Error Folder")
                {
                }
                field("EDI Notifications E-Mail"; Rec."EDI Notifications E-Mail")
                {
                }
                field("PO Filename Prefix"; Rec."PO Filename Prefix")
                {
                }
                field("PO Response Filename Prefix"; Rec."PO Response Filename Prefix")
                {
                }
                field("Ship. Advice Filename Prefix"; Rec."Ship. Advice Filename Prefix")
                {
                }
                field(Status; Rec.Status)
                {
                }
            }
        }
    }

    actions
    {
    }
}

