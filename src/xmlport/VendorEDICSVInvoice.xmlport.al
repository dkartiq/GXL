///<Summary>
//Import vendor invoice file into EDI-Purchase Messages
///</Summary>
xmlport 50356 "GXL Vendor-EDI CSV Invoice"
{
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = false;
    Caption = 'Vendor-EDI CSV Invoice';

    schema
    {
        textelement(EDIInvoice)
        {
            tableelement("EDI-Purchase Messages"; "GXL EDI-Purchase Messages")
            {
                AutoSave = true;
                XmlName = 'PurchaseDetails';
                SourceTableView = SORTING(ImportDoc) ORDER(Ascending);
                fieldelement(PurchaseOrderNumber; "EDI-Purchase Messages".DocumentNumber)
                {

                    trigger OnAfterAssignField()
                    var
                        ErrorMessage: Record "GXL EDI-Purchase Messages";
                        WMSSingleInstance: Codeunit "GXL WMS Single Instance";
                    begin
                        "EDI-Purchase Messages".ImportDoc := "EDI-Purchase Messages".ImportDoc::"2"; //Invoice
                        ErrorMessage.Reset();
                        ErrorMessage.SetFilter(DocumentNumber, "EDI-Purchase Messages".DocumentNumber);
                        ErrorMessage.SetRange("Error Found", true);
                        ErrorMessage.DeleteAll();

                        "EDI-Purchase Messages"."EDI File Log Entry No." := WMSSingleInstance.GetEDIFileLogEntryNo();
                        "EDI-Purchase Messages"."Vendor No." := WMSSingleInstance.GetEDIPartnerNo();
                    end;
                }
                textelement(LineNo)
                {

                    trigger OnAfterAssignVariable()
                    begin
                        Evaluate("EDI-Purchase Messages".LineReference, LineNo);
                    end;
                }
                fieldelement(Items; "EDI-Purchase Messages".Items)
                {

                    trigger OnAfterAssignField()
                    var
                        PurchaseLine: Record "Purchase Line";
                    begin
                        "EDI-Purchase Messages"."Error Found" := false;
                        "EDI-Purchase Messages"."Error Description" := '';

                        PurchaseLine.Reset();
                        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                        PurchaseLine.SetRange("Document No.", "EDI-Purchase Messages".DocumentNumber);
                        if not PurchaseLine.FindFirst() then begin
                            "EDI-Purchase Messages".SupplierNo := "EDI-Purchase Messages".Items;  // The data file contains the Supplier Item No. in the Items field
                            "EDI-Purchase Messages".Items := '';  // Clear value as this field should have the NAV Item No.
                            "EDI-Purchase Messages"."Error Found" := true;
                            "EDI-Purchase Messages"."Error Description" := StrSubstNo(Text000Txt, "EDI-Purchase Messages".DocumentNumber);
                        end else begin
                            // Assume Item Reference No. used on the data file is the Vendor Reorder No.
                            // Determine corresponding NAV Item No. from the PO
                            PurchaseLine.SetRange("GXL Vendor Reorder No.", "EDI-Purchase Messages".Items);
                            if PurchaseLine.FindFirst() then begin
                                "EDI-Purchase Messages".LineReference := PurchaseLine."Line No.";
                                "EDI-Purchase Messages".Items := PurchaseLine."No.";
                                "EDI-Purchase Messages".SupplierNo := PurchaseLine."GXL Vendor Reorder No.";
                                "EDI-Purchase Messages"."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                                "EDI-Purchase Messages".ILC := PurchaseLine."GXL Legacy Item No.";
                            end else begin
                                "EDI-Purchase Messages".SupplierNo := "EDI-Purchase Messages".Items;  // Move supplier no. from data file to this field
                                "EDI-Purchase Messages".Items := '';  // Clear value as this field represents the NAV Item No.
                                "EDI-Purchase Messages"."Error Found" := true;
                                "EDI-Purchase Messages"."Error Description" := StrSubstNo(Text002Txt, "EDI-Purchase Messages".SupplierNo, "EDI-Purchase Messages".DocumentNumber);
                            end;
                        end;

                    end;
                }
                fieldelement(GTIN; "EDI-Purchase Messages".GTIN)
                {
                }
                textelement(LineDescription)
                {

                    trigger OnAfterAssignVariable()
                    begin
                        "EDI-Purchase Messages".Description := CopyStr(LineDescription, 1, 100);
                    end;
                }
                fieldelement(QtyToInvoice; "EDI-Purchase Messages".QtyToInvoice)
                {
                }
                fieldelement(UnitCostExcl; "EDI-Purchase Messages".UnitCostExcl)
                {
                }
                fieldelement(LineAmountExcl; "EDI-Purchase Messages".LineAmountExcl)
                {
                }
                fieldelement(LineAmountIncl; "EDI-Purchase Messages".LineAmountIncl)
                {
                }
                fieldelement(VendorInvoiceNumber; "EDI-Purchase Messages".VendorInvoiceNumber)
                {
                }
                fieldelement(InvoiceDate; "EDI-Purchase Messages".InvoiceDate)
                {
                }
                fieldelement(Name; "EDI-Purchase Messages"."Supplier Name")
                {
                }
                fieldelement(ABN; "EDI-Purchase Messages"."Supplier ABN")
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    WMSSingleInstance: Codeunit "GXL WMS Single Instance";
                begin
                    "EDI-Purchase Messages".ImportDoc := "EDI-Purchase Messages".ImportDoc::"2"; //Invoice
                    "EDI-Purchase Messages"."EDI File Log Entry No." := WMSSingleInstance.GetEDIFileLogEntryNo();
                    "EDI-Purchase Messages"."Vendor No." := WMSSingleInstance.GetEDIPartnerNo();
                end;
            }

            trigger OnAfterAssignVariable()
            begin
                "EDI-Purchase Messages".ImportDoc := "EDI-Purchase Messages".ImportDoc::"2";
            end;
        }
    }



    var
        Text000Txt: Label 'Purchase Order No. %1 does not exist.';
        Text002Txt: Label 'Vendor Reorder No. %1 not found on Purchase Order No. %2';
}

