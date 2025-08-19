/// <summary>
/// ERP-NAV Master Data Management: Automate IC Transaction
/// </summary>
codeunit 50033 "GXL AutoImportICTrans-Process"
{
    TableNo = "IC Inbox Transaction";

    trigger OnRun()
    var
    begin
        CarryOutICInboxAction.SetTableView(Rec);
        CarryOutICInboxAction.RunModal();
    end;

    var
        CarryOutICInboxAction: Report "GXL AutoCompleteICInboxAction";
}

