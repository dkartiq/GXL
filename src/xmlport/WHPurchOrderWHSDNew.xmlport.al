// 001 9.07.2025 KDU HP2-SPRINT2
/*
//-- SR11766 30/11/2014 tad pv00.00
        New Format

      //--PSSC.00 SR11993 10/12/2014 nao pv00.01
        - Adjust XML contents according to testing feedback
        - Changed Ship to and to
        - Line Order number should Vendor Reorder No.
      //--SR11993 19/12/2014 nao pv00.02
        - Change Number = Location Code + PO Number

      //-- SR11766 22/12/2014 mcm pv00.03
        Change Request 3PL Contingency Plan
        Added Default File Name
*/
xmlport 50045 "WH-Purchase Order -WH-SD New"
{
    Caption = 'WH-Purchase Order -WH-SD New';
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    // UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/x50045';
    Encoding = UTF16;

    schema
    {
        textelement(PurchaseOrder)
        {
            tableelement(PurchaseHeader; "Purchase Header")
            {
                RequestFilterFields = "No.";
                SourceTableView = sorting("Document Type", "No.") where("Document Type" = const(Order), "GXL Source of Supply" = filter(1 | 0));
                MinOccurs = Once;
                MaxOccurs = Once;
                textelement(number1)
                {
                    XmlName = 'number';
                }
                textelement(Title) { }
                fieldelement(To; PurchaseHeader."Buy-from Vendor Name") { }
                textelement(ToName)
                {
                    XmlName = 'ShipTo';
                }
                // >> HP2-SPRINT2
                // fieldelement(Date; PurchaseHeader."Order Date") { }
                // fieldelement(RequiredDate; PurchaseHeader."Expected Receipt Date") { }
                textelement(Date)
                {
                    trigger OnBeforePassVariable()
                    begin
                        Date := Format(PurchaseHeader."Order Date", 0, '<Day,2>/<Month,2>/<Year,2>');
                    end;
                }
                textelement(RequiredDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        RequiredDate := Format(PurchaseHeader."Expected Receipt Date", 0, '<Day,2>/<Month,2>/<Year,2>');
                    end;
                }
                // << HP2-SPRINT2
                textelement(Requisitioner) { }
                textelement(Remarks) { }
                textelement(ShipVia) { }
                textelement(FOBPoint) { }
                textelement(Terms) { }
                textelement(Freight) { }
                fieldelement(ConfirmingTo; PurchaseHeader."Vendor Invoice No.") { }
                fieldelement(SubTotal; PurchaseHeader.Amount) { }
                textelement(Shipping) { }
                textelement(OtherFees) { }
                textelement(Tax1)
                {
                    XmlName = 'Tax';
                }
                fieldelement(Total; PurchaseHeader."Amount Including VAT") { }
                tableelement(Items; Integer)
                {
                    SourceTableView = sorting(Number) where(Number = const(1));
                    MinOccurs = Once;
                    MaxOccurs = Once;
                    tableelement(Item; "Purchase Line")
                    {
                        SourceTableView = sorting("Document Type", "Document No.", "Line No.") order(Ascending) where("Type" = const(Item), Quantity = filter(<> 0));
                        LinkTable = PurchaseHeader;
                        LinkFields = "Document Type" = field("Document Type"), "Document No." = field("No.");
                        MinOccurs = Once;
                        MaxOccurs = Unbounded;
                        fieldelement(Quantity; Item.Quantity) { }
                        fieldelement(Code; Item."No.") { }
                        fieldelement(OrderNumber; Item."GXL Vendor Reorder No.") { }
                        fieldelement(Description; Item.Description) { }
                        fieldelement(UnitPrice; Item."Direct Unit Cost") { }
                        fieldelement(TotalPrice; Item.Amount) { }
                        fieldelement(TaxRate; Item."VAT %") { }
                    }
                    trigger OnBeforeModifyRecord()
                    begin
                        RecPurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        RecPurchLine.SetRange("Document No.", PurchaseHeader."No.");
                    end;
                }
                trigger OnAfterGetRecord()
                var
                    Loc: Record Location;
                    number: Code[50];
                    Tax: Text;
                begin
                    Loc.Reset();
                    if Loc.Get(PurchaseHeader."Location Code") then begin
                        if StrPos(Loc."Phone No.", ')') > 0 then
                            Loc."Phone No." := DelStr(Loc."Phone No.", StrPos(Loc."Phone No.", ')'), 1);
                        if StrPos(Loc."Phone No.", '(') > 0 then
                            Loc."Phone No." := DelStr(Loc."Phone No.", StrPos(Loc."Phone No.", '('), 1);
                        if StrPos(Loc."Phone No.", ' ') > 0 then
                            Loc."Phone No." := DelStr(Loc."Phone No.", StrPos(Loc."Phone No.", ' '), 1);
                        if StrPos(Loc."Phone No.", ' ') > 0 then
                            Loc."Phone No." := DelStr(Loc."Phone No.", StrPos(Loc."Phone No.", ' '), 1);
                    end;

                    PurchaseHeader.CalcFields("Amount", "Amount Including VAT");
                    ToName := PurchaseHeader."Ship-to Name" + ' ' + PurchaseHeader."Ship-to Address" + ' ' +
                        PurchaseHeader."Ship-to City" + ', ' + PurchaseHeader."Ship-to Post Code" + ' Phone: ' + Loc."Phone No." + ' Fax: ' + ' Contact: ' + Loc.Contact;
                    Tax1 := Format(PurchaseHeader."Amount Including VAT" - PurchaseHeader."Amount");
                    number1 := '';
                    number1 := PurchaseHeader."Location Code" + '-' + PurchaseHeader."No.";
                    CurrXMLport.FILENAME(StrSubstNo(Text000, number));
                end;

            }
        }
    }

    PROCEDURE SetXmlFilter(StoreCode: Code[10]);
    BEGIN
        PurchaseHeader.SETRANGE("Location Code", StoreCode);
        PurchaseHeader.SETRANGE("Order Date", WORKDATE);
    END;

    PROCEDURE ShowNewPO(StoreCode: Code[10]);
    BEGIN
        PurchaseHeader.SETRANGE("Location Code", StoreCode);
        PurchaseHeader.SETFILTER("GXL Order Status", '%1|%2', PurchaseHeader."GXL Order Status"::New, PurchaseHeader."GXL Order Status"::Created);
    END;

    PROCEDURE ShowBatchPO(StoreCode: Code[10]; BatchId: Integer);
    BEGIN
        PurchaseHeader.SETRANGE("Location Code", StoreCode);
        //   PurchaseHeader.SETRANGE("PDA Integer",BatchId);
    END;

    var
        Text000: Label 'PO-%1';
        RecPurchLine: Record "Purchase Line";
}
