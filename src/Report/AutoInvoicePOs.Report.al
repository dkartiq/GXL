report 50002 "GXL Auto Invoice POs"
{
    /*
        Change log:
        ERP-293 CR116 - Auto Invoice changes
    */

    Caption = 'Auto Invoice POs';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;
    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            DataItemTableView = sorting("GXL Order Status") where("Document Type" = const(Order), "GXL Order Status" = filter(Closed)); //ERP-293 +
            RequestFilterFields = "No.", "Buy-from Vendor No.", "Pay-to Vendor No.";
            trigger OnAfterGetRecord()
            begin
                ProcessPurchaseOrder(PurchaseHeader);
            end;

            trigger OnPreDataItem()
            var
                PaymentMethod: Record "Payment Method";
                ToDate: Date;
            begin
                GetGLSetup();    //PS-2560-Cannot Post Claimed Purchase +
                GetPurchSetup();
                if ProcessOption in [ProcessOption::"Post Invoice", ProcessOption::All] then
                    PurchSetup.TestField("GXL BP Trans. Posted Inv. Nos.");
                PurchSetup.TestField("GXL BP Payment Method Code");
                PaymentMethod.Get(PurchSetup."GXL BP Payment Method Code");
                PaymentMethod.TestField("Bal. Account Type", PaymentMethod."Bal. Account Type"::"Bank Account");
                PaymentMethod.TestField("Bal. Account No.");

                if not (ProcessOption in [ProcessOption::"Post Invoice", ProcessOption::All]) then
                    CurrReport.Break();

            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(RunOption; ProcessOption)
                {
                    Caption = 'Process Option';
                    OptionCaption = 'Post Invoice,Complete PO,All';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnPreReport()
    begin
    end;

    trigger OnPostReport()
    begin
        if ProcessOption in [ProcessOption::"Complete PO", ProcessOption::All] then
            ClosePurchaseOrders();
    end;

    procedure ProcessPurchaseOrder(var PH: Record "Purchase Header")
    var
        AutoProcessPO: Codeunit "GXL Auto Proc. Purch. Order";
        Ok: Boolean;
    begin
        Commit();
        Clear(AutoProcessPO);
        AutoProcessPO.SetNoPaymentPosting(false); //ERP-293 auto payment + 
        AutoProcessPO.SetGLSetup(GLSetup, SourceCodeSetup); //PS-2560-Cannot Post Claimed Purchase +
        AutoProcessPO.SetPurchSetup(PurchSetup);
        AutoProcessPO.SetProcessOption(0);
        Ok := AutoProcessPO.Run(PH);
    end;

    local procedure ClosePurchaseOrders()
    var
        PH: Record "Purchase Header";
        AutoProcessPO: Codeunit "GXL Auto Proc. Purch. Order";
        Ok: Boolean;
    begin
        PH.SetCurrentKey("GXL Order Status");
        PH.SetRange("GXL Order Status", PH."GXL Order Status"::Closed);
        PH.SetRange("Document Type", PH."Document Type"::Order);
        if PH.FindSet() then
            repeat
                Commit();
                Clear(AutoProcessPO);
                AutoProcessPO.SetNoPaymentPosting(true); //ERP-293 no auto payment +
                AutoProcessPO.SetGLSetup(GLSetup, SourceCodeSetup); //PS-2560-Cannot Post Claimed Purchase +
                AutoProcessPO.SetPurchSetup(PurchSetup);
                AutoProcessPO.SetProcessOption(1);
                Ok := AutoProcessPO.Run(PH);
            until PH.Next() = 0;
    end;

    //PS-1807 - Moved functions to codeunit to handle errors
    /*
    procedure ProcessPurchaseOrder(PH: Record "Purchase Header")
    var
        PH2: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
        OrigPaymentMethodCode: Code[10];
    begin
        IF NOT HasReceiptInTimeframe(PH) then
            exit;
        IF NOT UpdatePurchaseLines(PH) then
            exit;
        PH.Receive := false;
        PH.Invoice := true;
        PH."Posting No. Series" := PurchSetup."GXL BP Trans. Posted Inv. Nos.";
        IF PH."Vendor Invoice No." = '' then
            PH.Validate("Vendor Invoice No.", PH."No.");
        PH.Validate("Posting Date", ReturnPostingDate(PH."Posting Date"));
        OrigPaymentMethodCode := PH."Payment Method Code";
        PH.Validate("Payment Method Code", PurchSetup."GXL BP Payment Method Code");
        PH.Modify(true);
        Commit();
        IF NOT PurchPost.Run(PH) then
            exit;
        IF PH2.Get(PH."Document Type", PH."No.") then begin
            PH2.Validate("Payment Method Code", OrigPaymentMethodCode);
            PH2.Modify(true);
        end;
    end;


    procedure HasReceiptInTimeframe(PH: Record "Purchase Header"): Boolean
    var
        PR: Record "Purch. Rcpt. Header";
    begin
        PR.SetCurrentKey("Order No.");
        PR.SetRange("Order No.", PH."No.");
        PR.SetFilter("Posting Date", '>=%1', WorkDate() - PurchSetup."GXL BP Receipt Age Days");
        exit(NOT PR.IsEmpty());
    end;

    procedure UpdatePurchaseLines(PH: Record "Purchase Header") HasSomethingToInvoice: Boolean
    var
        PL: Record "Purchase Line";
    begin
        PL.SetRange("Document No.", PH."No.");
        PL.SetRange("Document Type", PH."Document Type");
        HasSomethingToInvoice := false;
        IF PL.FindSet(true, false) then
            repeat
                IF PL."Qty. to Invoice" <> PL."Qty. Rcd. Not Invoiced" then begin
                    pl.Validate("Qty. to Invoice", pl."Qty. Rcd. Not Invoiced");
                    PL.Modify(true);
                end;
                IF Pl."Qty. to Invoice" <> 0 then
                    HasSomethingToInvoice := true;
            until PL.Next() = 0;
    end;

    procedure ReturnPostingDate(ReceiptDate: Date) PostingDate: Date
    var
        InvPeriod: Record "Inventory Period";
    begin
        if InvPeriod.IsEmpty() then
            exit(ReceiptDate);
        PostingDate := ReceiptDate;
        IF NOT InvPeriod.IsValidDate(PostingDate) then
            PostingDate := PostingDate + 1;
    end;
    */

    procedure GetPurchSetup()
    begin
        if PurchSetupGot then
            exit;
        PurchSetup.Get();
        PurchSetupGot := true;
    end;

    //PS-2560-Cannot Post Claimed Purchase +
    local procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            SourceCodeSetup.Get();
            GLSetupRead := true;
        end;
    end;
    //PS-2560-Cannot Post Claimed Purchase -


    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        PurchSetupGot: Boolean;
        ProcessOption: Option "Post Invoice","Complete PO",All;
        GLSetupRead: Boolean;

}