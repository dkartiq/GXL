codeunit 50035 "GXL Sales Events Mgt."
{

    //ERP-NAV Master Data Management: Automate IC Transaction +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20];
        InvtPickPutaway: Boolean; CommitIsSuppressed: Boolean)
    begin
        AutomateICTransactions(SalesHeader, SalesInvHdrNo, SalesCrMemoHdrNo, CommitIsSuppressed);
    end;

    local procedure AutomateICTransactions(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean)
    var
        AutoExportICTrans: Codeunit "GXL Auto Export IC Trans";
    begin
        if SalesHeader."Sell-to IC Partner Code" = '' then
            exit;

        if not CommitIsSuppressed then
            Commit();

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order,
            SalesHeader."Document Type"::Invoice:
                if SalesInvHdrNo <> '' then
                    AutoExportICTrans.ProcessSalesDocument(SalesInvHdrNo);

            SalesHeader."Document Type"::"Credit Memo",
            SalesHeader."Document Type"::"Return Order":
                if SalesCrMemoHdrNo <> '' then
                    AutoExportICTrans.ProcessSalesDocument(SalesCrMemoHdrNo);
        end;
    end;
    //ERP-NAV Master Data Management: Automate IC Transaction -

    //PS-2523 VET Clinic transfer order +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeItemJnlPostLine', '', false, false)]
    local procedure OnBeforeItemJnlPostLine(var ItemJournalLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header")
    begin
        ItemJournalLine."GXL MIM User ID" := SalesHeader."GXL MIM User ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeFinalizePosting', '', false, false)]
    local procedure OnBeforeFinalizePosting(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."GXL MIM User ID" := '';
    end;
    //PS-2523 VET Clinic transfer order -
}