page 50386 "GXL Vendor Invoice Messages"
{
    Caption = 'Vendor Invoice Message List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL EDI-Purchase Messages";
    SourceTableView = sorting(ImportDoc, DocumentNumber, Items) where(ImportDoc = const("2"));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field("Error Found"; Rec."Error Found")
                {
                    ApplicationArea = All;
                }
                field(ImportDoc; Rec.ImportDoc)
                {
                    ApplicationArea = All;
                }
                field(DocumentNumber; Rec.DocumentNumber)
                {
                    ApplicationArea = All;
                }
                field(LineReference; Rec.LineReference)
                {
                    ApplicationArea = All;
                }
                field(GTIN; Rec.GTIN)
                {
                    ApplicationArea = All;
                }
                field(SupplierNo; Rec.SupplierNo)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(ConfirmedReceiptDate; Rec.ConfirmedReceiptDate)
                {
                    ApplicationArea = All;
                }
                field(QtyToInvoice; Rec.QtyToInvoice)
                {
                    ApplicationArea = All;
                }
                field(UnitCostExcl; Rec.UnitCostExcl)
                {
                    ApplicationArea = All;
                }
                field(LineAmountExcl; Rec.LineAmountExcl)
                {
                    ApplicationArea = All;
                }
                field(LineAmountIncl; Rec.LineAmountIncl)
                {
                    ApplicationArea = All;
                }
                field(VendorInvoiceNumber; Rec.VendorInvoiceNumber)
                {
                    ApplicationArea = All;
                }
                field(InvoiceDate; Rec.InvoiceDate)
                {
                    ApplicationArea = All;
                }
                field("Error Description"; Rec."Error Description")
                {
                    ApplicationArea = All;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    ApplicationArea = All;
                }
                field("Supplier ABN"; Rec."Supplier ABN")
                {
                    ApplicationArea = All;
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
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
            group(Functions)
            {
                Caption = 'Functions';
                action(ResetErr)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Error';
                    Image = ResetStatus;

                    trigger OnAction();
                    var
                        EDIMessage: Record "GXL EDI-Purchase Messages";
                    begin
                        EDIMessage.Reset();
                        CurrPage.SetSelectionFilter(EDIMessage);
                        EDIMessage.SetCurrentKey(Processed, "Error Found");
                        EDIMessage.SetRange("Error Found", true);
                        EDIMessage.ModifyAll("Error Found", false);
                        EDIMessage.ModifyAll("Error Description", '');
                    end;
                }
            }
        }
    }
}