/// <summary>
/// NAV9-11 Integrations
/// </summary>
codeunit 50027 "GXL Insert Cancel NAVOrder Log"
{
    Permissions = tabledata "GXL Cancel NAV Order Log" = i;

    trigger OnRun()
    begin
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        DocumentType: Option Purchase,Transfer;
        DocumentNo: Code[20];
        SetupRead: Boolean;


    procedure SetPurchaseDocument(NewPurchHead: Record "Purchase Header")
    var
    begin
        DocumentType := DocumentType::Purchase;
        DocumentNo := NewPurchHead."No.";
    end;

    procedure SetTransferDocument(NewTransHead: Record "Transfer Header")
    var
    begin
        DocumentType := DocumentType::Transfer;
        DocumentNo := NewTransHead."No.";
    end;

    local procedure GetSetup()
    var
    begin
        if not SetupRead then begin
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;

    local procedure AddCancelNAVOrderLog()
    var
        CancelNAVOrderLog: Record "GXL Cancel NAV Order Log";
    begin
        CancelNAVOrderLog.Init();
        CancelNAVOrderLog."Entry No." := 0;
        CancelNAVOrderLog."Document Type" := DocumentType;
        CancelNAVOrderLog."No." := DocumentNo;
        CancelNAVOrderLog.Insert(true);
    end;

    procedure CancelNAVPurchaseOrder(PurchHead: Record "Purchase Header")
    var
    begin
        GetSetup();
        if not IntegrationSetup."Sync Cancel NAV Purchase Order" then
            exit;
        SetPurchaseDocument(PurchHead);
        AddCancelNAVOrderLog();
    end;

    procedure CancelNAVTransferOrder(TransHead: Record "Transfer Header");
    var
    begin
        GetSetup();
        if not IntegrationSetup."Sync Cancel NAV Transfer Order" then
            exit;
        SetTransferDocument(TransHead);
        AddCancelNAVOrderLog();
    end;

}