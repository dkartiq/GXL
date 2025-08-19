page 50047 "GXL Purchase/Transfer Orders"
{
    /*
    001 24.03.2022  PREM    LCB-4   New Fields created i.e. "ASN Required", "ASN Created", "ASN No."", "ASN Received"
    ERP-295 19-08-2021
    */

    Caption = 'Purchase/Transfer Orders';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Purchase/Transfer Order";
    Editable = false;
    SourceTableTemporary = true;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                FreezeColumn = "Store No.";
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowOrder();
                    end;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                // >> 001
                field("ASN Required"; Rec."ASN Required") { }
                field("ASN Received"; Rec."ASN Received") { }
                field("ASN Created"; Rec."ASN Created")
                {
                    TRIGGER OnDrillDown()
                    VAR
                        ASNLine: Record "GXL ASN Level 1 Line";
                        WhMsgLine: Record "GXL WH Message Lines";
                    BEGIN
                        IF NOT Rec."ASN Created" THEN
                            EXIT;

                        CASE Rec."Document Type" OF
                            Rec."Document Type"::Purchase:
                                BEGIN
                                    ASNLine.SetRange("Document Type", ASNLine."Document Type"::Purchase);
                                    ASNLine.SetRange("Document No.", Rec."ASN No.");
                                    PAGE.RUN(PAGE::"GXL GX Pallet Lines", ASNLine);
                                END;
                            Rec."Document Type"::Transfer:
                                BEGIN
                                    WhMsgLine.SetRange("Import Type", WhMsgLine."Import Type"::"Transfer Order");
                                    WhMsgLine.SetRange("Document No.", Rec."No.");
                                    PAGE.RUN(PAGE::"GXL 3PL Packing Slip", WhMsgLine);
                                END;
                        END;


                    END;
                }
                field("ASN No."; Rec."ASN No.") { }
                // << 001
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    // >> 001
                    TRIGGER OnDrillDown()
                    VAR
                        PurchLine: Record "Purchase Line";
                        TransLine: Record "Transfer Line";
                    BEGIN
                        CASE Rec."Document Type" OF
                            Rec."Document Type"::Purchase:
                                BEGIN
                                    PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                                    PurchLine.SetRange("Document No.", Rec."No.");
                                    PAGE.RUN(0, PurchLine);
                                END;
                            Rec."Document Type"::Transfer:
                                BEGIN
                                    TransLine.SetRange("Document No.", Rec."No.");
                                    PAGE.RUN(0, TransLine);
                                END;
                        END;
                    END;
                    // << 001
                }
                field("Store-from No."; Rec."Store-from No.")
                {
                    ApplicationArea = All;
                }
                field("Store-from Name"; Rec."Store-from Name")
                {
                    ApplicationArea = All;
                }
                field("Store-to No."; Rec."Store-to No.")
                {
                    ApplicationArea = All;
                }
                field("Store-to Name"; Rec."Store-to Name")
                {
                    ApplicationArea = All;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(ShowOrderAct)
            {
                Caption = 'View Order';
                ApplicationArea = All;
                Image = Order;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    ShowOrder();
                end;
            }
            action(RefreshOrders)
            {
                Caption = 'Refresh Orders';
                ApplicationArea = All;
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    GetOrders(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        GetSetup();
        GetOrders(Rec);
    end;

    var
        RetailUser: Record "LSC Retail User";
        SetupRead: Boolean;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            if not RetailUser.Get(UserId()) then
                Clear(RetailUser);
            SetupRead := true;
        end;
    end;

    local procedure GetOrders(var TempPurchTransOrder: Record "GXL Purchase/Transfer Order" temporary)
    var
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
        // >> 001
        Loc: Record Location;
        WhMsgLine: Record "GXL WH Message Lines";
        TransLine: Record "Transfer Line";
        OrderAmt: Decimal;
        // << 001
        Windows: Dialog;
    begin
        GetSetup();
        Windows.Open('Building Open Purchase/Transfer Orders\Please Wait...');
        TempPurchTransOrder.Reset();
        TempPurchTransOrder.DeleteAll();

        PurchHead.SetCurrentKey("GXL Order Status");
        PurchHead.SetFilter("GXL Order Status", '<>%1', PurchHead."GXL Order Status"::Closed);
        PurchHead.SetRange("Document Type", PurchHead."Document Type"::Order);
        if RetailUser."Location Code" <> '' then
            PurchHead.SetRange("Location Code", RetailUser."Location Code");
        PurchHead.SetAutoCalcFields("GXL ASN Created", "GXL ASN Number", Amount); // >> 001 <<
        if PurchHead.FindSet(false) then
            repeat
                TempPurchTransOrder.Init();
                TempPurchTransOrder."Document Type" := TempPurchTransOrder."Document Type"::Purchase;
                TempPurchTransOrder."No." := PurchHead."No.";
                TempPurchTransOrder."Vendor No." := PurchHead."Buy-from Vendor No.";
                TempPurchTransOrder."Vendor Name" := PurchHead."Buy-from Vendor Name";
                TempPurchTransOrder."Expected Receipt Date" := PurchHead."Expected Receipt Date";
                TempPurchTransOrder."Store No." := PurchHead."LSC Store No.";
                TempPurchTransOrder."Posting Date" := PurchHead."Posting Date";
                TempPurchTransOrder."Currency Code" := PurchHead."Currency Code";
                // >> 001
                IF PurchHead."GXL EDI Vendor Type" IN [PurchHead."GXL EDI Vendor Type"::VAN, PurchHead."GXL EDI Vendor Type"::"Point 2 Point", PurchHead."GXL EDI Vendor Type"::"Point 2 Point Contingency"] THEN
                    TempPurchTransOrder."ASN Required" := TRUE;
                TempPurchTransOrder."ASN Created" := PurchHead."GXL ASN Created";
                TempPurchTransOrder."ASN No." := PurchHead."GXL ASN Number";
                TempPurchTransOrder."ASN Received" := PurchHead."GXL ASN File Received";
                TempPurchTransOrder.Amount := PurchHead.Amount;
                // << 001
                TempPurchTransOrder.Insert();

            until PurchHead.Next() = 0;

        TransHead.SetFilter("GXL Order Status", '%1', TransHead."GXL Order Status"::Confirmed); //already Shipped
        if RetailUser."Location Code" <> '' then
            TransHead.SetRange("Transfer-to Code", RetailUser."Location Code");
        if TransHead.FindSet(false) then
            repeat
                TempPurchTransOrder.Init();
                TempPurchTransOrder."Document Type" := TempPurchTransOrder."Document Type"::Transfer;
                TempPurchTransOrder."No." := TransHead."No.";
                TempPurchTransOrder."Expected Receipt Date" := TransHead."Receipt Date";
                TempPurchTransOrder."Store No." := TransHead."LSC Store-to";
                TempPurchTransOrder."Store-from No." := TransHead."LSC Store-from";
                TempPurchTransOrder."Store-from Name" := TransHead."Transfer-from Name";
                TempPurchTransOrder."Store-to No." := TransHead."LSC Store-to";
                TempPurchTransOrder."Store-to Name" := TransHead."Transfer-to Name";
                TempPurchTransOrder."Posting Date" := TransHead."Posting Date";
                // >> 001
                IF Loc.Code <> TransHead."Transfer-from Code" THEN
                    IF NOT Loc.GET(TransHead."Transfer-from Code") THEN
                        Loc.RESET;
                TempPurchTransOrder."ASN Required" := Loc."GXL 3PL Warehouse";

                WhMsgLine.SetRange("Document No.", TransHead."No.");
                IF NOT WhMsgLine.IsEmpty THEN BEGIN
                    TempPurchTransOrder."ASN Created" := TRUE;
                    TempPurchTransOrder."ASN No." := TransHead."No.";
                    TempPurchTransOrder."ASN Received" := TRUE;
                END;
                OrderAmt := 0;
                TransLine.SetRange("Document No.", TransHead."No.");
                TransLine.SetRange("Transfer-from Code", TransHead."Transfer-from Code");
                IF TransLine.FindSet() THEN
                    repeat
                        IF TransLine."Quantity Shipped" <> 0 THEN
                            OrderAmt += TransLine."Quantity Shipped" * TransLine."GXL Unit Cost"
                        ELSE
                            OrderAmt += TransLine.Quantity * TransLine."GXL Unit Cost"
                    until TransLine.next = 0;
                TempPurchTransOrder.Amount := OrderAmt;
                // << 001                
                TempPurchTransOrder.Insert();

            until TransHead.Next() = 0;
        Windows.Close();
    end;

    local procedure ShowOrder()
    var
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
    begin
        case Rec."Document Type" of
            Rec."Document Type"::Purchase:
                begin
                    if PurchHead.Get(PurchHead."Document Type"::Order, Rec."No.") then begin
                        PurchHead.SetRecFilter();
                        Page.RunModal(Page::"Purchase Order", PurchHead);
                    end;
                end;
            Rec."Document Type"::Transfer:
                begin
                    if TransHead.Get(Rec."No.") then begin
                        TransHead.SetRecFilter();
                        Page.RunModal(Page::"Transfer Order", TransHead);
                    end;
                end;
        end;
    end;

}