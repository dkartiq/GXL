pageextension 50031 "GXL Posted Purchase Receipt" extends "Posted Purchase Receipt"
{
    layout
    {
        //ERP-NAV Master Data Management +
        addlast(General)
        {
            field("GXL International Order"; Rec."GXL International Order")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter(Shipping)
        {
            group("GXL InternationalShipment")
            {
                Caption = 'Internaltional Shipment';
                Visible = Rec."GXL International Order";

                field("GXL Port of Loading Code"; Rec."GXL Port of Loading Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Port of Arrival Code"; Rec."GXL Port of Arrival Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                group("GXL OrderDate")
                {
                    ShowCaption = false;
                    field("GXL Order Date"; Rec."Order Date")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    grid("GXL OrderGrid")
                    {
                        GridLayout = Rows;
                        group("GXL VendorShipmentDate")
                        {
                            Caption = 'Vendor Shipment Date';
                            field("GXL Orig. Vendor Shipment Date"; Rec."GXL Orig. Vendor Shipment Date")
                            {
                                ApplicationArea = All;
                                Caption = 'Original';
                                Editable = false;
                            }
                            field("GXL Vendor Shipment Date"; Rec."GXL Vendor Shipment Date")
                            {
                                ApplicationArea = All;
                                Caption = 'Expected/Actual';
                                Editable = false;
                            }
                        }
                        group("GXL PortArrivalDate")
                        {
                            Caption = 'Port Arrival Date';
                            field("GXL Original Port Arrival Date"; Rec."GXL Original Port Arrival Date")
                            {
                                ApplicationArea = All;
                                Editable = false;
                                ShowCaption = false;
                            }
                            field("GXL Port Arrival Date"; Rec."GXL Port Arrival Date")
                            {
                                ApplicationArea = All;
                                Editable = false;
                                ShowCaption = false;
                            }
                        }
                        group("GXL DCReceiptDate")
                        {
                            Caption = 'DC Receipt Date';
                            field("GXL Original DC Receipt Date"; Rec."GXL Original DC Receipt Date")
                            {
                                ApplicationArea = All;
                                Editable = false;
                                ShowCaption = false;
                            }
                            field("GXL DC Receipt Date"; Rec."GXL DC Receipt Date")
                            {
                                ApplicationArea = All;
                                Editable = false;
                                ShowCaption = false;
                            }
                        }
                    }
                    field("GXL Expected Receipt Date"; Rec."Expected Receipt Date")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
                group("GXL ContainerInfo")
                {
                    ShowCaption = false;
                    field("GXL Import Agent Number"; Rec."GXL Import Agent Number")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Incoterms Code"; Rec."GXL Incoterms Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Shipment Method Code"; Rec."Shipment Method Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Shipment Load Type"; Rec."GXL Shipment Load Type")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Container No."; Rec."GXL Container No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Container Type"; Rec."GXL Container Type")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Container Carrier"; Rec."GXL Container Carrier")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Container Vessel"; Rec."GXL Container Vessel")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Total Order Qty"; Rec."GXL Total Order Qty")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Total Ordered Quantity"; Rec."GXL Total Ordered Quantity")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Total Weight"; Rec."GXL Total Weight")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("GXL Total Cubage"; Rec."GXL Total Cubage")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
        //ERP-NAV Master Data Management -

    }
}