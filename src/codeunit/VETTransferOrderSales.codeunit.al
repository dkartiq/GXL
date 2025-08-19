/// <summary>
/// PS-2523 VET Clinic transfer order
/// </summary>
codeunit 50277 "GXL VET Transfer Order-Sales"
{
    TableNo = "GXL PDA-TransShpt Process Buff";

    trigger OnRun()
    var
        SalesHead: Record "Sales Header";
        SalesInvHead: Record "Sales Invoice Header";
        SavedProcessWhat: Option " ",Create,Post;
    begin
        SavedProcessWhat := ProcessWhat;
        ClearAll();
        ProcessWhat := SavedProcessWhat;

        PDATransShptProcessBuff := Rec;
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", Rec."No.");
        PDATransShptProcessBuff.FindSet();

        case ProcessWhat of
            ProcessWhat::Create:
                begin
                    if not TransRcptHead.Get(PDATransShptProcessBuff."Transfer Receipt No.") then begin
                        TransRcptHead.SetCurrentKey("Transfer Order No.");
                        TransRcptHead.SetRange("Transfer Order No.", PDATransShptProcessBuff."No.");
                        TransRcptHead.FindLast();
                    end;
                    TransRcptLine.SetRange("Document No.", TransRcptHead."No.");
                    CreateSalesOrder(SalesHead);
                end;
            ProcessWhat::Post:
                begin
                    if not SalesHead.Get(SalesHead."Document Type"::Order, PDATransShptProcessBuff."Sales Order No.") then begin
                        //Order was posted manually, so exit
                        SalesInvHead.SetCurrentKey("Order No.");
                        SalesInvHead.SetRange("Order No.", PDATransShptProcessBuff."Sales Order No.");
                        SalesInvHead.FindLast();
                        InvoiceNo := SalesInvHead."No.";
                    end else
                        PostSalesOrder(SalesHead);
                end;
            else
                Error('%1 is not supported', ProcessWhat);
        end;
        Commit();

        Rec := PDATransShptProcessBuff;
    end;


    var
        GLSetup: Record "General Ledger Setup";
        IntegrationSetup: Record "GXL Integration Setup";
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        TransRcptHead: Record "Transfer Receipt Header";
        TransRcptLine: Record "Transfer Receipt Line";
        Cust: Record Customer;
        SetupRead: Boolean;
        ProcessWhat: Option " ",Create,Post;
        SalesOrderNo: Code[20];
        InvoiceNo: Code[20];

    procedure SetProcess(NewProcessWhat: Option " ",Create,Post)
    begin
        ProcessWhat := NewProcessWhat;
    end;

    local procedure GetSetup()
    var
        SalesHead2: Record "Sales Header";
    begin
        if not SetupRead then begin
            GLSetup.Get();
            IntegrationSetup.Get();
            IntegrationSetup.TestField("VET Customer No.");
            IntegrationSetup.TestField("VET Intercompany G/L Account");
            Cust.Get(IntegrationSetup."VET Customer No.");
            Cust.CheckBlockedCustOnDocs(Cust, SalesHead2."Document Type"::Order, false, false);
            SetupRead := true;
        end;
    end;

    local procedure CreateSalesHeader(var SalesHead: Record "Sales Header")
    var
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        StoreDimValue: Code[20];
    begin
        SalesHead.Init();
        SalesHead."Document Type" := SalesHead."Document Type"::Order;
        SalesHead."No." := '';
        SalesHead.Insert(true);

        SalesHead.SetHideValidationDialog(true);
        //Force so that location code cannot be overriden by retail user
        SalesHead."LSC Store No." := '';
        SalesHead.Validate("Sell-to Customer No.", IntegrationSetup."VET Customer No.");
        SalesHead.Validate("Posting Date", WorkDate());
        SalesHead.Validate("Document Date", PDATransShptProcessBuff."Shipment Date");
        //Force so that location code cannot be overriden by retail user
        SalesHead."LSC Store No." := '';
        SalesHead.Validate("Location Code", TransRcptHead."Transfer-to Code");
        SalesHead."Your Reference" := TransRcptHead."Transfer Order No.";
        SalesHead."External Document No." := TransRcptHead."External Document No.";
        if SalesHead."External Document No." = '' then
            SalesHead."External Document No." := TransRcptHead."Transfer Order No.";
        SalesHead."GXL VET Store Code" := TransRcptHead."GXL VET Store Code";
        SalesHead."Bal. Account Type" := SalesHead."Bal. Account Type"::"G/L Account";
        SalesHead."Bal. Account No." := IntegrationSetup."VET Intercompany G/L Account";
        SalesHead."GXL MIM User ID" := PDATransShptProcessBuff."MIM User ID";

        if (IntegrationSetup."Store Dimension Code" <> '') and (SalesHead."LSC Store No." <> '') then begin
            StoreDimValue := MiscUtilities.GetStoreDimensionValue(SalesHead."LSC Store No.", IntegrationSetup."Store Dimension Code");
            case IntegrationSetup."Store Dimension Code" of
                GLSetup."Shortcut Dimension 1 Code":
                    SalesHead.Validate("Shortcut Dimension 1 Code", StoreDimValue);
                GLSetup."Shortcut Dimension 2 Code":
                    SalesHead.Validate("Shortcut Dimension 2 Code", StoreDimValue);
                GLSetup."Shortcut Dimension 3 Code":
                    SalesHead.ValidateShortcutDimCode(3, StoreDimValue);
                GLSetup."Shortcut Dimension 4 Code":
                    SalesHead.ValidateShortcutDimCode(4, StoreDimValue);
                GLSetup."Shortcut Dimension 5 Code":
                    SalesHead.ValidateShortcutDimCode(5, StoreDimValue);
                GLSetup."Shortcut Dimension 6 Code":
                    SalesHead.ValidateShortcutDimCode(6, StoreDimValue);
                GLSetup."Shortcut Dimension 7 Code":
                    SalesHead.ValidateShortcutDimCode(7, StoreDimValue);
                GLSetup."Shortcut Dimension 8 Code":
                    SalesHead.ValidateShortcutDimCode(8, StoreDimValue);
            end;
        end;

        SalesHead.Modify(true);
    end;

    local procedure CreateSalesLines(SalesHead: Record "Sales Header")
    begin
        if TransRcptLine.FindSet() then
            repeat
                CreateSalesLine(SalesHead);
            until TransRcptLine.Next() = 0;
    end;

    local procedure CreateSalesLine(SalesHead: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHead."Document Type";
        SalesLine."Document No." := SalesHead."No.";
        SalesLine."Line No." := TransRcptLine."Line No.";
        SalesLine.Insert(true);
        SalesLine.SetHideValidationDialog(true);
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", TransRcptLine."Item No.");
        SalesLine.Validate("Unit of Measure Code", TransRcptLine."Unit of Measure Code");
        SalesLine.Validate(Quantity, TransRcptLine.Quantity);
        SalesLine.Validate("Unit Price", SalesLine."Unit Cost");
        SalesLine.Modify(true);
    end;

    procedure CreateSalesOrder(var SalesHead: Record "Sales Header")
    begin
        GetSetup();
        CreateSalesHeader(SalesHead);
        CreateSalesLines(SalesHead);
        SalesOrderNo := SalesHead."No.";
    end;

    procedure PostSalesOrder(var SalesHead: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        if SalesHead."Posting Date" <> WorkDate() then begin
            SalesHead."Posting Date" := WorkDate();
            SalesHead.Validate("Currency Code");
            SalesHead.Modify();
        end;
        SalesHead.Ship := true;
        SalesHead.Invoice := true;
        SalesPost.Run(SalesHead);
        InvoiceNo := SalesHead."Last Posting No.";
    end;

    procedure GetSalesOrderNo(var NewSalesOrderNo: Code[20])
    begin
        NewSalesOrderNo := SalesOrderNo;
    end;

    procedure GetPostedInvoiceNo(var NewInvoiceNo: Code[20])
    begin
        NewInvoiceNo := InvoiceNo;
    end;


}