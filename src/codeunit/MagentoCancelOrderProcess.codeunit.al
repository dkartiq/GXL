/// <summary>
/// PS-2423 Magento web order cancelled
/// </summary>
// 001 18.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-726 
codeunit 50045 "GXL MagentoCancelOrder-Process"
{
    trigger OnRun()
    begin
        //Data was populated from external source (SQL)
        SelectLatestVersion();

        RunCode(GlobalMagentoCancelledOrd);
    end;

    var
        GlobalMagentoCancelledOrd: Record "GXL Magento Cancelled Order";
        Windows: Dialog;


    procedure SetMagentoCancelledOrder(var NewMagentoCancelledOrd: Record "GXL Magento Cancelled Order")
    begin
        GlobalMagentoCancelledOrd.Copy(NewMagentoCancelledOrd);
    end;

    local procedure RunCode(var MagentoCancelledOrd: Record "GXL Magento Cancelled Order")
    var
        // >> 001
        //TempDocumentSearchResult: Record "Document Search Result" temporary;
        TempMagentoCancelledOrd: Record "GXL Magento Cancelled Order" temporary;
    // << 001
    begin
        // >> 001
        // TempDocumentSearchResult.Reset();
        // TempDocumentSearchResult.DeleteAll();

        // GetUniqueMagentoTransID(MagentoCancelledOrd, TempDocumentSearchResult);
        TempMagentoCancelledOrd.Reset();
        TempMagentoCancelledOrd.DeleteAll();

        GetUniqueMagentoTransID(MagentoCancelledOrd, TempMagentoCancelledOrd);
        // << 001 
        if GuiAllowed then
            Windows.Open(
                'Cancelling Magento web orders\\' +
                'Transaction ID    #1#########');
        // >> 001  
        // if TempDocumentSearchResult.Find('-') then  
        //     repeat  
        //         if GuiAllowed then  
        //             Windows.Update(1, TempDocumentSearchResult."Doc. No.");  

        //         Commit();  
        //         CancelPerMagentoTransID(TempDocumentSearchResult."Doc. No.");  
        //     until TempDocumentSearchResult.Next() = 0;  
        // TempDocumentSearchResult.DeleteAll();  
        if TempMagentoCancelledOrd.Find('-') then
            repeat
                if GuiAllowed then
                    Windows.Update(1, TempMagentoCancelledOrd."Magento WebOrder Trans. ID");

                Commit();
                CancelPerMagentoTransID(TempMagentoCancelledOrd."Magento WebOrder Trans. ID");
            until TempMagentoCancelledOrd.Next() = 0;
        TempMagentoCancelledOrd.DeleteAll();
        // << 001   
        if GuiAllowed then
            Windows.Close();
    end;
    // >> 001
    //local procedure CancelPerMagentoTransID(TransID: Code[20])
    local procedure CancelPerMagentoTransID(TransID: Code[50])
    // << 001  
    var
        MagentoCancelledOrd: Record "GXL Magento Cancelled Order";
        POSTransaction: Record "LSc POS Transaction";
        MagentoWebOrd: Record "GXL Magento Web Order";
    begin
        if not MagentoCancelledOrd.Get(TransID) then
            exit;

        if MagentoCancelledOrd.Processed then
            exit;

        POSTransaction.SetCurrentKey("GXL Magento WebOrder Trans. ID");
        POSTransaction.SetRange("GXL Magento WebOrder Trans. ID", TransID);
        if POSTransaction.FindFirst() then
            POSTransaction.Delete(true);

        MagentoWebOrd.Reset();
        MagentoWebOrd.SetCurrentKey("Transaction ID");
        MagentoWebOrd.SetRange("Transaction ID", TransID);
        if not MagentoWebOrd.IsEmpty then
            MagentoWebOrd.DeleteAll(true);

        MagentoCancelledOrd.Processed := true;
        MagentoCancelledOrd.Modify();

    end;
    // >> 001 
    // local procedure GetUniqueMagentoTransID(var MagentoCancelledOrd: Record "GXL Magento Cancelled Order"; var TempDocumentSearchResult: Record "Document Search Result" temporary)
    // begin
    //     MagentoCancelledOrd.SetCurrentKey(Processed);
    //     MagentoCancelledOrd.SetRange(Processed, false);
    //     if MagentoCancelledOrd.FindSet() then
    //         repeat
    //             if MagentoCancelledOrd."Magento WebOrder Trans. ID" <> '' then
    //                 if not TempDocumentSearchResult.Get(0, MagentoCancelledOrd."Magento WebOrder Trans. ID", 0) then begin
    //                     TempDocumentSearchResult.Init();
    //                     TempDocumentSearchResult."Doc. No." := MagentoCancelledOrd."Magento WebOrder Trans. ID";
    //                     TempDocumentSearchResult.Insert();
    //                 end;
    //         until MagentoCancelledOrd.Next() = 0;
    // end; 
    local procedure GetUniqueMagentoTransID(var MagentoCancelledOrd: Record "GXL Magento Cancelled Order"; var TempMagentoCancelledOrd: Record "GXL Magento Cancelled Order" temporary)
    begin
        MagentoCancelledOrd.SetCurrentKey(Processed);
        MagentoCancelledOrd.SetRange(Processed, false);
        if MagentoCancelledOrd.FindSet() then
            repeat
                if MagentoCancelledOrd."Magento WebOrder Trans. ID" <> '' then
                    if not TempMagentoCancelledOrd.Get(MagentoCancelledOrd."Magento WebOrder Trans. ID") then begin
                        TempMagentoCancelledOrd.Init();
                        TempMagentoCancelledOrd."Magento WebOrder Trans. ID" := MagentoCancelledOrd."Magento WebOrder Trans. ID";
                        TempMagentoCancelledOrd.Insert();
                    end;
            until MagentoCancelledOrd.Next() = 0;
    end;
    // << 001 
}