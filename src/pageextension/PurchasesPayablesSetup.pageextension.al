pageextension 50019 "GXL Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Default Accounts")
        {
            group("GXL BatchPosting")
            {
                Caption = 'Batch Posting';
                /*
                field("GXL BP Vendor No."; "GXL BP Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("GXL BP Bank Acc. No."; "GXL BP Bank Acc. No.")
                {
                    ApplicationArea = All;
                }
                field("GXL BP Purchase G/L Acc. No."; "GXL BP Purchase G/L Acc. No.")
                {
                    ApplicationArea = All;
                }
                */
                field("GXL BP Payment Method Code"; Rec."GXL BP Payment Method Code")
                {
                    ApplicationArea = All;
                }
                // field("GXL BP Transitional Inv. Nos."; "GXL BP Transitional Inv. Nos.")
                // {
                //     ApplicationArea = All;
                // }
                field("GXL BP Trans. Posted Inv. Nos."; Rec."GXL BP Trans. Posted Inv. Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'When Auto Invoice POs function is run, the posted invoice numbers will be generated from this number series.';
                }
                field("GXL BP Receipt Age Days"; Rec."GXL BP Receipt Age Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'When Auto Invoice POs function is run, only receipts younger than this number of days will be invoiced.';
                }
            }
            group(LocalFunctionality)
            {
                // >> LCB-250
                field("GXL EDI Validate VendReord No."; Rec."GXL EDI Validate VendReord No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'A tick mark will validate Vendor Reorder No. while EDI document processing.';
                }
                // << LCB-250
            }

        }
        // >> HP2-SPRINT2
        addafter("Order Nos.")
        {
            field("Import Order Nos."; Rec."Import Order Nos.")
            {
                ApplicationArea = All;
            }
        }
        // << HP2-SPRINT2
    }
}