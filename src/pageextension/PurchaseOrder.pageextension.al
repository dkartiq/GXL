// 003  18.07.2025  BY   HP2-Sprint3-Changes HAR2-69
// 002 05.07.2025 KDU HP2-Sprint2
pageextension 50010 "GXL Purchase Order" extends "Purchase Order"
{
    /*Change Log
        ERP-397 26-10-21 LP: Exflow and Purchase Order Creation
    */
    // 001  19.03.2022  KDU  GX-202201 ERP-355 Blocked sending order to vendor and printing purchase order report.

    layout
    {
        addafter("Foreign Trade")
        {
            group("GXL GXLSupplyChain")
            {
                Caption = 'Supply Chain';

                field("GXL Order Status"; Rec."GXL Order Status")
                {
                    ApplicationArea = All;
                }
                field("GXL Order Type"; Rec."GXL Order Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Manual PO"; Rec."GXL Manual PO")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Order"; Rec."GXL EDI Order")
                {
                    ApplicationArea = All;
                }
                field("GXL Source of Supply"; Rec."GXL Source of Supply")
                {
                    ApplicationArea = All;
                }
                field("GXL Transport Type"; Rec."GXL Transport Type")
                {
                    ApplicationArea = All;
                }
                //group("GXL ThreePLGrp")
                //{
                //Caption = 'Third Party Data';
                group("GXL ASN")
                {
                    ShowCaption = false;
                    field("GXL ASN Created"; Rec."GXL ASN Created")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL ASN File Received"; Rec."GXL ASN File Received")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL ASN Number"; Rec."GXL ASN Number")
                    {
                        ApplicationArea = All;
                    }
                }
                field("GXL Audit Flag"; Rec."GXL Audit Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Freight Forwarder Code"; Rec."GXL Freight Forwarder Code")
                {
                    ApplicationArea = All;
                    // Visible = false;
                }
                //}

                group("GXL EDI")
                {
                    Caption = 'EDI';
                    field("GXL EDI Vendor Type"; Rec."GXL EDI Vendor Type")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL EDI Order in Out. Pack UoM"; Rec."GXL EDI Order in Out. Pack UoM")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL EDI PO File Log Entry No."; Rec."GXL EDI PO File Log Entry No.")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Last EDI Document Status"; Rec."GXL Last EDI Document Status")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL 3PL EDI"; Rec."GXL 3PL EDI")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }

        }
        //ERP-NAV Master Data Management +
        addlast(General)
        {
            field("GXL International Order"; Rec."GXL International Order")
            {
                ApplicationArea = All;
                Editable = false;
            }
            // >> 001
            field("GXL Trade PO"; Rec.IsTradePO(Rec."No.")) { Editable = false; }
            // << 001
        }
        addafter("Shipping and Payment")
        {
            group("GXL InternationalShipment")
            {
                Caption = 'Internaltional Shipment';
                Visible = Rec."GXL International Order";

                field("GXL Departure Port"; Rec."GXL Departure Port")
                {
                    ApplicationArea = All;
                }
                field("GXL Arrival Port"; Rec."GXL Arrival Port")
                {
                    ApplicationArea = All;
                }
                field("GXL Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                group("GXL OrderDate")
                {
                    ShowCaption = false;
                    field("GXL Order Date"; Rec."Order Date")
                    {
                        ApplicationArea = All;
                    }
                    grid("GXL OrderGrid")
                    {
                        GridLayout = Rows;
                        group("GXL VendorShipmentDate")
                        {
                            Caption = 'Vendor Shipment Date';
                            field("GXL Expected Shipment Date"; Rec."GXL Expected Shipment Date")
                            {
                                ApplicationArea = All;
                                Caption = 'Original';
                            }
                            field("GXL Vendor Shipment Date"; Rec."GXL Vendor Shipment Date")
                            {
                                ApplicationArea = All;
                                Caption = 'Expected/Actual';
                            }
                        }
                        group("GXL PortDepartureDate")
                        {
                            Caption = 'Port Departure Date';
                            field("GXL Original Port Departure Date"; Rec."GXL Org Port Departure Date")
                            {
                                ApplicationArea = All;
                                ShowCaption = false;
                            }
                            field("GXL Actual Port Departure Date"; Rec."GXL Actual Port Departure Date")
                            {
                                ApplicationArea = All;
                                ShowCaption = false;
                            }
                        }
                        group("GXL PortArrivalDate")
                        {
                            Caption = 'Port Arrival Date';
                            field("GXL Into Port Arrival Date"; Rec."GXL Into Port Arrival Date")
                            {
                                ApplicationArea = All;
                                ShowCaption = false;
                            }
                            field("GXL Port Arrival Date"; Rec."GXL Port Arrival Date")
                            {
                                ApplicationArea = All;
                                ShowCaption = false;
                            }
                        }
                        group("GXL DCReceiptDate")
                        {
                            Caption = 'DC Receipt Date';
                            field("GXL Into DC Delivery Date"; Rec."GXL Into DC Delivery Date")
                            {
                                ApplicationArea = All;
                                ShowCaption = false;
                            }
                            field("GXL DC Receipt Date"; Rec."GXL DC Receipt Date")
                            {
                                ApplicationArea = All;
                                ShowCaption = false;
                            }
                        }
                    }
                    field("GXL Expected Receipt Date"; Rec."Expected Receipt Date")
                    {
                        ApplicationArea = All;
                    }
                }
                group("GXL ContainerInfo")
                {
                    ShowCaption = false;
                    field("GXL Import Agent Number"; Rec."GXL Import Agent Number")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Incoterms Code"; Rec."GXL Incoterms Code")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Shipment Method Code"; Rec."Shipment Method Code")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Shipment Load Type"; Rec."GXL Shipment Load Type")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Container No."; Rec."GXL Container No.")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Container Type"; Rec."GXL Container Type")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Container Carrier"; Rec."GXL Container Carrier")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Container Vessel"; Rec."GXL Container Vessel")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Total Order Qty"; Rec."GXL Total Order Qty")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Total Ordered Qty. Unit"; Rec."GXL Total Ordered Qty. Unit")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Total Weight"; Rec."GXL Total Weight")
                    {
                        ApplicationArea = All;
                    }
                    field("GXL Total Cubage"; Rec."GXL Total Cubage")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
        //ERP-NAV Master Data Management -

        //ERP-397+
        addlast("Invoice Details")
        {
            field("GXL Auto Invoice Error Msg"; Rec."GXL Auto Invoice Error Msg")
            {
                ApplicationArea = All;
            }
        }
        //ERP-397-
        // >> 003
        addafter(Prepayment)
        {
            group("Thrid Party Data")
            {
                Caption = 'Thrid Party Data';
                field("GXL 3PL"; Rec."GXL 3PL")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL 3PL File Sent"; Rec."GXL 3PL File Sent")
                {
                    ApplicationArea = All;
                }
                field("GXL 3PL File Receive"; Rec."GXL 3PL File Receive")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL 3PL Cancel Request Sent"; Rec."GXL 3PL Cancel Request Sent")
                {
                    ApplicationArea = All;
                }
                field("GXL 3PL Cancel Request Receieved"; Rec."GXL 3PL Cancel Req Receieved")
                {
                    ApplicationArea = All;
                }
                field("GXL 3PL File Sent Date"; Rec."GXL 3PL File Sent Date")
                {
                    ApplicationArea = All;
                }
                field("GXL 3PL Cancel Date"; Rec."GXL 3PL Cancel Date")
                {
                    ApplicationArea = All;
                }
                field("GXL 3PL File Update"; Rec."GXL 3PL File Updated")
                {
                    ApplicationArea = All;
                }
                field("GXL PDA Integer"; Rec."GXL PDA Integer")
                {
                    ApplicationArea = All;
                }
                field("GXL Vendor File Exchange"; Rec."GXL Vendor File Exchange")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Vendor File Sent"; Rec."GXL Vendor File Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor File Sent field.', Comment = '%';
                }
                field("GXL Vendor File Sent Date"; Rec."GXL Vendor File Sent Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor File Sent Date field.', Comment = '%';
                }
                field("GXL Order Conf. Received"; Rec."GXL Order Conf. Received")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Confirmation Received field.', Comment = '%';
                }
                field("GXL Order Confirmation Date"; Rec."GXL Order Confirmation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Confirmation Date field.', Comment = '%';
                }
                field("GXL ASN File Received (2)"; Rec."GXL ASN File Received")
                {
                    Caption = 'ASN File Received';
                    ApplicationArea = All;
                }
                field("GXL Invoice Received"; Rec."GXL Invoice Received")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Received field.', Comment = '%';
                }
                field("GXL Invoice Received Date"; Rec."GXL Invoice Received Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Received Date field.', Comment = '%';
                }
            }
        }
        // << 003
    }
    // >> 001
    actions
    {
        modify(SendCustom)
        {
            Enabled = Rec.Status = Rec.Status::Released;
        }
        modify("&Print")
        {
            Enabled = Rec.Status = Rec.Status::Released;
        }
        // >> 002
        addafter(SendCustom)
        {
            action(SendEmail)
            {
                ApplicationArea = All;
                Image = Email;
                Caption = 'Send Email';
                Promoted = true;
                PromotedCategory = Category10;
                PromotedOnly = true;
                trigger OnAction()
                var
                    EmailManagement: Codeunit "GXL Email Management";
                begin
                    EmailManagement.SetManual(true);
                    EmailManagement.SendPOEmail(Rec, true, true);
                end;
            }
        }
        // << 002
        // >> 003
        addlast(processing)
        {
            action(Export)
            {
                ApplicationArea = all;
                caption = 'Export PO Lines';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    PurchLine: Record "Purchase Line";
                begin
                    PurchLine.ExportPurchLines(Rec."No.");
                end;
            }
            action(Import)
            {
                ApplicationArea = all;
                caption = 'Import PO Lines';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    PurchLine: Record "Purchase Line";
                begin
                    PurchLine.ImportPurchaseLinesFromExcel(Rec);
                end;
            }
            // << 003
        }
        // << 001
        addlast(navigation)
        {
            action("Change Order Status")
            {
                ApplicationArea = All;
                Caption = 'Change Order Status';
                Image = ChangeStatus;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PurchHdr: Record "Purchase Header";
                begin
                    PurchHdr.get(Rec.RecordId);
                    PurchHdr.Mark(true);
                    PurchHdr.MarkedOnly(true);
                    Rec.PerformOrderStatusChange(PurchHdr);
                end;
            }
        }
    }
}