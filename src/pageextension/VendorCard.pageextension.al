//  LCB-3  23-09-2022  PREM    New field "Post Credit Claim On Receipt" added. 
pageextension 50009 "GXL Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Registration)
        {
            group("GXL GXLSupplyChain")
            {
                Caption = 'Supply Chain';
                field("GXL Supplier Planner"; Rec."GXL Supplier Planner")
                {
                    ApplicationArea = All;
                }
                field("GXL Minimum Order Quantity"; Rec."GXL Minimum Order Quantity")
                {
                    ApplicationArea = All;
                }
                field("GXL Minimum Order Value"; Rec."GXL Minimum Order Value")
                {
                    ApplicationArea = All;
                }
                field("GXL Rolled-Out"; Rec."GXL Rolled-Out")
                {
                    ApplicationArea = All;
                }
                //ERP-NAV Master Data Management +
                field("GXL Email Type"; Rec."GXL Email Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Email On Posting"; Rec."GXL Email On Posting")
                {
                    ApplicationArea = All;
                }
                field("GXL Email To"; Rec."GXL Email To")
                {
                    ApplicationArea = All;
                }
                //ERP-NAV Master Data Management -
                //ERP-293 +
                field("GXL Disable Auto Invoice"; Rec."GXL Disable Auto Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the non-EDI purchase orders for this vendor are excluded in the auto-invoice process';
                }
                //ERP-293 -
                field("GXL Post Credit ClaimOnReceipt"; Rec."GXL Post Credit ClaimOnReceipt")  // >> LCB-3 << new field added
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a credit claim should be posted while receiving the material if actual quantity is short.';
                    Enabled = Rec."GXL Disable Auto Invoice";
                }
            }
            group("GXL GXLEDIGroup")
            {
                Caption = 'EDI';
                field("GXL EDI Order in Out. Pack UoM"; Rec."GXL EDI Order in Out. Pack UoM")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Flag"; Rec."GXL EDI Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Ullaged Supplier"; Rec."GXL Ullaged Supplier")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Vendor Type"; Rec."GXL EDI Vendor Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Post / Send Claims"; Rec."GXL Post / Send Claims")
                {
                    ApplicationArea = All;
                }
                field("GXL Acc. Lower Cost Purch. Inv"; Rec."GXL Acc. Lower Cost Purch. Inv")
                {
                    ApplicationArea = All;
                }
                field("GXL PO File Format"; Rec."GXL PO File Format")
                {
                    ApplicationArea = All;
                }
                field("GXL PO Email Address"; Rec."GXL PO Email Address")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Supplier No. Source"; Rec."GXL EDI Supplier No. Source")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Email Address"; Rec."GXL EDI Email Address")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Inbound Directory"; Rec."GXL EDI Inbound Directory")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Outbound Directory"; Rec."GXL EDI Outbound Directory")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Archive Directory"; Rec."GXL EDI Archive Directory")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Error Directory"; Rec."GXL EDI Error Directory")
                {
                    ApplicationArea = All;
                }
                // >> HP2-SPRINT2
                field("GXL EDI Cancel"; Rec."GXL EDI Cancel")
                {
                    ApplicationArea = All;
                }
                // << HP2-SPRINT2
            }
        }
        addlast("Foreign Trade")
        {
            // TODO International/Domestic PO - Not needed for now
            group("GXL InternationalShipment")
            {
                ShowCaption = false;
                //ERP-NAV Master Data Management +
                field("GXL Import Flag"; Rec."GXL Import Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Import Vendor/Agent"; Rec."GXL Import Vendor/Agent")
                {
                    ApplicationArea = All;
                }
                field("GXL Incoterms Code"; Rec."GXL Incoterms Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Port of Loading"; Rec."GXL Port of Loading")
                {
                    ApplicationArea = All;
                }
                field("GXL Freight Forwarder Code"; Rec."GXL Freight Forwarder Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Agent Number"; Rec."GXL Agent Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Shipment Load Type"; Rec."GXL Shipment Load Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Consolidated Freight Shpt"; Rec."GXL Consolidated Freight Shpt")
                {
                    ApplicationArea = All;
                }
                //ERP-NAV Master Data Management -

            }
        }
        // >> LCB-203  
        addafter("Lead Time Calculation")
        {
            field("GXL Override OP/OM Calc."; Rec."GXL Override OP/OM Calc.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Override OP/OM Calculation field.';
            }
        }
        // << LCB-203
        // >> HP2-SPRINT2
        addlast("LSC ASN")
        {
            group(Localfunction)
            {
                Caption = 'Local Functionality';
                field("PO Address from Company"; Rec."PO Address from Company")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
            }

        }
        // >> HP2-SPRINT2
    }

    actions
    {
        addlast(Navigation)
        {
            action("GXL GXL3PLFileSetup")
            {
                ApplicationArea = All;
                Caption = 'File Exchange Setup';
                Image = SetupList;
                RunObject = page "GXL 3PL File Setup";
                RunPageLink = Code = field("No.");
            }
        }
    }
}