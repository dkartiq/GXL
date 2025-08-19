report 50356 "GXL PO Receiving Discrepancy"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/POReceivingDiscrepancy.rdlc';
    Caption = 'PO Receiving Discrepancy';
    ApplicationArea = All;
    UsageCategory = Administration;


    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            //TODO: Order Status - Receiving discrepancy report for Closed status
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order), "GXL Order Status" = FILTER(Closed));
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Purchase Order';
            column(CompanyName; COMPANYNAME())
            {
            }
            column(DocumentType_PurchHdr; "Document Type")
            {
            }
            column(No_PurchHdr; "No.")
            {
            }
            column(ItemCostExVATCaption; Text50003Lbl)
            {
            }
            column(TotalCostExVATCaption; Text50004Lbl)
            {
            }
            column(TotalCostIncVATCaption; Text50005Lbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(POType; POType)
                {
                }
                column(CompanyInfoPicture; CompanyInfo.Picture)
                {
                }
                column(SelltoCustNo_PurchHdr; "Purchase Header"."Sell-to Customer No.")
                {
                }
                column(OutputNo; OutputNo)
                {
                }
                column(VATBaseDisc_PurchHdr; "Purchase Header"."VAT Base Discount %")
                {
                }
                column(PricesInclVATtxt; PricesInclVATtxt)
                {
                }
                column(BuyfromVendorNo_PurchHdr; "Purchase Header"."Buy-from Vendor No.")
                {
                }
                column(DocDate_PurchHdr; FORMAT("Purchase Header"."Document Date", 0, 4))
                {
                }
                column(PricesIncVAT_PurchHdr; "Purchase Header"."Prices Including VAT")
                {
                }
                column(OrderNoCaption; OrderNoCaptionLbl)
                {
                }
                column(DocDateCaption; DocDateCaptionLbl)
                {
                }
                column(DeliveryDate; FORMAT("Purchase Header"."Expected Receipt Date"))
                {
                }
                // TODO International/Domestic PO - Not needed for now
                // >> HP2-SPRINT2
                column(JDALoadID; "Purchase Header"."GXL JDA Load ID")
                {
                }

                // column(JDALoadID; '0')
                // {
                // }
                // << HP2-SPRINT2
                column(OrderDate; FORMAT("Purchase Header"."Order Date"))
                {
                }
                column(SourceOfSupply; FORMAT("Purchase Header"."GXL Source of Supply"))
                {
                }
                dataitem(PurchLines; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(PurchLineLineAmt; PurchLine."Line Amount")
                    {
                        AutoFormatExpression = PurchLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(Desc_PurchLine; PurchLine.Description)
                    {
                    }
                    column(LineNo_PurchLine; PurchLine."Line No.")
                    {
                    }
                    column(Type_PurchLine; FORMAT(PurchLine.Type, 0, 2))
                    {
                    }
                    column(No_PurchLine; PurchLine."No.")
                    {
                    }
                    column(QtyRec; PurchLine."Qty. to Receive")
                    {
                    }
                    column(DirectUnitCost_PurchLine; PurchLine."Direct Unit Cost")
                    {
                        AutoFormatExpression = "Purchase Header"."Currency Code";
                        AutoFormatType = 2;
                    }
                    column(TotalAmt; TotalAmount)
                    {
                    }
                    column(LineAmt_PurchLine; PurchLine.Amount)
                    {
                        AutoFormatExpression = "Purchase Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(Amt_PurchLine; PurchLine."Amount Including VAT")
                    {
                    }
                    column(VendReorderNo; PurchLine."GXL Vendor Reorder No.")
                    {
                    }
                    // >> Upgrade
                    //column(GTIN; PurchLine."Cross-Reference No.")
                    column(GTIN; PurchLine."Item Reference No.")
                    {
                    }
                    // << Upgrade
                    column(ASNQty; PurchLine."GXL Rec. Variance")
                    {
                    }
                    column(GSTAmt; VATAmount)
                    {
                    }
                    column(QtyDiff; PurchLine."GXL ASN Rec. Variance")
                    {
                    }
                    column(TotalAmtIncGST; TotalAmountInclVAT)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        IF Number = 1 THEN
                            PurchLine.FIND('-')
                        ELSE
                            PurchLine.Next();


                        TotalAmount += PurchLine.Amount;
                        TotalAmountInclVAT += PurchLine."Amount Including VAT";
                    end;

                    trigger OnPostDataItem()
                    begin
                        PurchLine.DeleteAll();
                    end;

                    trigger OnPreDataItem()
                    begin
                        SETRANGE(Number, 1, PurchLine.COUNT());
                    end;
                }
                dataitem(Total; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                }

                trigger OnAfterGetRecord()
                var
                begin
                    CLEAR(PurchLine);
                    CLEAR(PurchPost);
                    PurchLine.DeleteAll();
                    GetPurchLineDiscrepancy();
                    OutputNo := OutputNo + 1;

                    TotalSubTotal := 0;
                    TotalAmount := 0;
                    TotalAmountInclVAT := 0;
                end;

                trigger OnPreDataItem()
                begin
                    OutputNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                // >> Upgrade
                //CurrReport.LANGUAGE := LanguageG.GetLanguageID("Language Code");
                CurrReport.LANGUAGE := LanguageG.GetLanguageIdOrDefault("Language Code");
                // << Upgrade
                CompanyInfo.Get();
                CompanyInfo.CALCFIELDS(Picture);
                FormatAddr.Company(CompanyAddr, CompanyInfo);

                BuyFromVendor.Reset();
                IF BuyFromVendor.GET("Buy-from Vendor No.") THEN;


                Location.Reset();
                IF "Location Code" <> '' THEN
                    Location.GET("Location Code");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
        PurchSetup.Get();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        PurchLine: Record "Purchase Line" temporary;
        // >> Upgrade
        //Language: Record Language;
        LanguageG: Codeunit Language;
        // << Upgrade
        PurchSetup: Record "Purchases & Payables Setup";
        BuyFromVendor: Record Vendor;
        Location: Record Location;
        FormatAddr: Codeunit "Format Address";
        PurchPost: Codeunit "Purch.-Post";
        CompanyAddr: array[8] of Text[100];
        OutputNo: Integer;
        VATAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        PricesInclVATtxt: Text[30];
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        POType: Text;
        OrderNoCaptionLbl: Label 'Order No.';
        DocDateCaptionLbl: Label 'Document Date';
        Text50003Lbl: Label 'Item Cost Excl. VAT';
        Text50004Lbl: Label 'Total Cost Excl. VAT (difference)';
        Text50005Lbl: Label 'Total Cost Incl. VAT (difference)';

    [Scope('OnPrem')]
    procedure GetPurchLineDiscrepancy()
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SETRANGE("Document No.", "Purchase Header"."No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        PurchaseLine.SETFILTER("GXL Rec. Variance", '<>0');
        IF PurchaseLine.FindSet() THEN
            REPEAT

                PurchLine.INIT();
                PurchLine.TRANSFERFIELDS(PurchaseLine);
                PurchLine."GXL Rec. Variance" := 0;
                PurchLine."GXL ASN Rec. Variance" := 0;
                PurchLine.Amount := 0;
                PurchLine."Amount Including VAT" := 0;
                PurchLine.Quantity := PurchaseLine."GXL Rec. Variance";
                PurchLine."GXL ASN Rec. Variance" := PurchaseLine."GXL Rec. Variance";
                PurchLine."Qty. to Receive" := PurchaseLine."Quantity Received";
                PurchLine."GXL Rec. Variance" := PurchaseLine.Quantity;
                PurchLine.Amount := PurchLine."GXL ASN Rec. Variance" * PurchaseLine."Direct Unit Cost";
                PurchLine."Amount Including VAT" := PurchLine.Amount * (1.1);

                PurchLine.INSERT();

            UNTIL PurchaseLine.Next() = 0;
    end;
}

