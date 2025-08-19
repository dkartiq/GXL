xmlport 50258 "GXL PDA-Transfer Order"
{
    Caption = 'PDA-TransferOrder';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/TransferOrder';
    Encoding = UTF16;

    schema
    {
        textelement(PDATransferOrder)
        {
            tableelement(TransferOrderHeader; "Transfer Header")
            {
                UseTemporary = true;
                MinOccurs = Zero;
                MaxOccurs = Unbounded;

                fieldelement(TransferNo; TransferOrderHeader."No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(FromCode; TransferOrderHeader."Transfer-from Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(FromName; TransferOrderHeader."Transfer-from Name")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ToCode; TransferOrderHeader."Transfer-to Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ToName; TransferOrderHeader."Transfer-to Name")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ShipDate; TransferOrderHeader."Shipment Date")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassField()
                    begin
                        if TransferOrderHeader."Shipment Date" = 0D then
                            TransferOrderHeader."Shipment Date" := WorkDate();
                    end;
                }
                fieldelement(OrderDate; TransferOrderHeader."GXL Order Date")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassField()
                    begin
                        if TransferOrderHeader."GXL Order Date" = 0D then
                            TransferOrderHeader."GXL Order Date" := WorkDate();
                    end;
                }
                fieldelement(DeliverDate; TransferOrderHeader."GXL Delivery Date")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassField()
                    begin
                        if TransferOrderHeader."GXL Delivery Date" = 0D then
                            TransferOrderHeader."GXL Delivery Date" := DMY2Date(1, 1, 1900);
                    end;
                }
                textelement(OrderStatus)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        OrderStatus := Format(TransferOrderHeader."GXL Order Status");
                    end;
                }
                fieldelement(TotalQty; TransferOrderHeader."GXL Staging Order Quantity")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                tableelement(TransferOrderLine; "Transfer Line")
                {
                    UseTemporary = true;
                    LinkTable = TransferOrderHeader;
                    LinkFields = "Document No." = field("No.");
                    MinOccurs = Zero;
                    MaxOccurs = Unbounded;

                    fieldelement(LineTransferNo; TransferOrderLine."Document No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(LineNo; TransferOrderLine."Line No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(ItemNo; TransferOrderLine."Item No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(UOM; TransferOrderLine."Unit of Measure Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(Description; TransferOrderLine.Description)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(OrderQuantity; TransferOrderLine.Quantity)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(QtyToReceive; TransferOrderLine."Qty. to Receive")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(QtyToShip; TransferOrderLine."Qty. to Ship")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(QtyShipped; TransferOrderLine."Quantity Shipped")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    textelement(UnitCost)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;

                        trigger OnBeforePassVariable()
                        begin
                            GetUnitCost();
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var
        TransHead: Record "Transfer Header";
        StagingTransHead: Record "GXL PDA-Staging Trans. Header";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        SelectOption: Option Staging,Actual,All;
        PostingOption: Option " ",Ship,Receive;

    procedure ShowFromTransfers(StoreCode: Code[10])
    begin
        TransHead.SetRange("Transfer-from Code", StoreCode);

        PopulateRec(SelectOption::Actual, PostingOption::Ship);

        TransferOrderHeader.SetRange("Transfer-from Code", StoreCode);
    end;

    procedure ShowToTransfers(StoreCode: Code[10])
    begin
        TransHead.SetRange("Transfer-to Code", StoreCode);
        //TODO: Order status
        //TransHead.SetRange("GXL Order Status", TransHead."GXL Order Status"::Confirmed);
        TransHead.SetRange("GXL Source of Supply", TransHead."GXL Source of Supply"::SD);

        PopulateRec(SelectOption::Actual, PostingOption::Receive);

        TransferOrderHeader.SetRange("Transfer-to Code", StoreCode);
    end;

    procedure ShowBatchTransferOrder(StoreCode: Code[10]; BatchId: Integer)
    begin
        StagingTransHead.SetRange("Transfer-from Code", StoreCode);
        StagingTransHead.SetRange("PDA Batch Id", BatchId);

        PopulateRec(SelectOption::Staging, PostingOption::" ");
    end;

    procedure ShowTransferOrder(DocumentNumber: Code[20])
    begin
        StagingTransHead.SetRange("No.", DocumentNumber);

        TransHead.SetRange("No.", DocumentNumber);

        PopulateRec(SelectOption::All, PostingOption::" ");

        TransferOrderHeader.SetRange("No.", DocumentNumber);
    end;

    local procedure PopulateRec(NewSelectOption: Option Staging,Actual,All; NewPostingOption: Option " ",Ship,Receive)
    var
        TransLine: Record "Transfer Line";
        StagingTransLine: Record "GXL PDA-Staging Trans. Line";
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
        PDATransRcptLine: Record "GXL PDA-Trans Receipt Line";
    begin
        if NewSelectOption in [NewSelectOption::Staging, NewSelectOption::All] then begin
            if not StagingTransHead.IsEmpty() then begin
                StagingTransHead.SetAutoCalcFields("Total Order Quantity");
                if StagingTransHead.FindSet() then
                    repeat
                        StagingTransLine.SetRange("Document No.", StagingTransHead."No.");
                        if StagingTransLine.FindSet() then begin
                            TransferOrderHeader.Init();
                            TransferOrderHeader.TransferFields(StagingTransHead);
                            TransferOrderHeader."GXL Order Status" := TransferOrderHeader."GXL Order Status"::Created;
                            TransferOrderHeader."GXL Staging Order Quantity" := StagingTransHead."Total Order Quantity";
                            TransferOrderHeader.Insert();

                            repeat
                                TransferOrderLine.Init();
                                TransferOrderLine.TransferFields(StagingTransLine);
                                TransferOrderLine.Insert();
                            until StagingTransLine.Next() = 0;
                        end;
                    until StagingTransHead.Next() = 0;
            end;
        end;

        if NewSelectOption in [NewSelectOption::Actual, NewSelectOption::All] then begin
            if not TransHead.IsEmpty() then begin
                TransHead.SetAutoCalcFields("GXL Total Order Quantity");
                if TransHead.FindSet() then
                    repeat
                        TransLine.SetRange("Document No.", TransHead."No.");
                        TransLine.SetRange("Derived From Line No.", 0);
                        if NewPostingOption = NewPostingOption::Ship then
                            TransLine.SetFilter("Outstanding Quantity", '<>0');
                        if NewPostingOption = NewPostingOption::Receive then
                            TransLine.SetFilter("Qty. in Transit", '<>0');
                        if TransLine.FindSet() then begin
                            TransferOrderHeader.Init();
                            TransferOrderHeader.TransferFields(TransHead);
                            TransferOrderHeader."GXL Staging Order Quantity" := TransHead."GXL Total Order Quantity";
                            TransferOrderHeader.Insert();

                            repeat
                                TransferOrderLine.Init();
                                TransferOrderLine.TransferFields(TransLine);
                                if PDATransShptLine.Get(TransLine."Document No.", TransLine."Line No.") then begin
                                    if TransferOrderLine."Qty. to Ship" > PDATransShptLine.Quantity then
                                        TransferOrderLine."Qty. to Ship" := TransferOrderLine."Qty. to Ship" - PDATransShptLine.Quantity
                                    else
                                        TransferOrderLine."Qty. to Ship" := 0;
                                end;
                                if PDATransRcptLine.Get(TransLine."Document No.", TransLine."Line No.") then begin
                                    if TransferOrderLine."Qty. to Receive" > PDATransRcptLine.Quantity then
                                        TransferOrderLine."Qty. to Receive" := TransferOrderLine."Qty. to Receive" - PDATransRcptLine.Quantity
                                    else
                                        TransferOrderLine."Qty. to Receive" := 0;
                                end;
                                TransferOrderLine.Insert();
                            until TransLine.Next() = 0;

                            TransferOrderLine.Reset();
                            TransferOrderLine.SetRange("Document No.", TransHead."No.");
                            if NewPostingOption = NewPostingOption::Ship then
                                TransferOrderLine.SetFilter("Qty. to Ship", '>0');
                            if NewPostingOption = NewPostingOption::Receive then
                                TransferOrderLine.SetFilter("Qty. to Receive", '>0');
                            if TransferOrderLine.IsEmpty() then begin
                                TransferOrderLine.SetRange("Qty. to Ship");
                                TransferOrderHeader.Delete();
                                TransferOrderLine.DeleteAll();
                            end;
                        end;

                    until TransHead.Next() = 0;
            end;
        end;

        TransferOrderHeader.SetCurrentKey("No.");
        TransferOrderHeader.Ascending(false);
        TransferOrderLine.Reset();
    end;

    local procedure GetUnitCost()
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Location Code", TransferOrderHeader."Transfer-from Code");
        SKU.SetRange("Item No.", TransferOrderLine."Item No.");
        if SKU.FindFirst() then
            UnitCost := Format(PDAItemIntegration.GetSKUCostPrice(Item, SKU), 0, 9)
        else
            if Item.Get(TransferOrderLine."Item No.") then
                UnitCost := Format(PDAItemIntegration.GetItemCostPrice(Item), 0, 9)
            else
                UnitCost := '0';
    end;
}