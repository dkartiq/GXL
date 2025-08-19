page 50003 "GXL Supply Chain Setup"
{
    /*Change Log
        CR029: Average Cost trapping: New field to archive logging before
        
        CR100-BatchAdjustCostItems: Added field "Batch Adj. Cost Error Email"

        PS-2400 15-02-2021 LP
            Added group Reporting and fields
        
        ERP-NAV Master Data Management: New field to specify if ranging is active or not
    */

    Caption = 'Supply Chain Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GXL Supply Chain Setup";
    InsertAllowed = false;
    DelayedInsert = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Product Ranging';
                //ERP-NAV Master Data Management +
                field("Ranging Is Active"; Rec."Ranging Is Active")
                {
                    ApplicationArea = All;
                }
                //ERP-NAV Master Data Management -
                field("Illegal Product Range Email"; Rec."Illegal Product Range Email")
                {
                    ApplicationArea = All;
                }
                // >> HP2-SPRINT2
                field("GXL Default Transportation Mode"; Rec."GXL Default Transportation Mode")
                {
                    ApplicationArea = All;
                }
                // << HP2-SPRINT2
            }
            //+ CR029
            group(Inventory)
            {
                Caption = 'Inventory Setup';
                field("AvgCostLog Archive Before"; Rec."AvgCostLog Archive Before")
                {
                    ApplicationArea = All;
                }
                //ERP-278-Duplicate average cost change log +
                field("Enable Average Cost Change Log"; Rec."Enable Average Cost Change Log")
                {
                    ApplicationArea = All;
                }
                field("Adjust Cost Items - Commit per"; Rec."Adjust Cost Items - Commit per")
                {
                    ApplicationArea = All;
                }
                //ERP-278-Duplicate average cost change log -
                //ERP-304-Batch Adjust cost record start/end time +
                field("Log Adjust Cost Start/End Time"; Rec."Log Adjust Cost Start/End Time")
                {
                    ApplicationArea = All;
                }
                //ERP-304-Batch Adjust cost record start/end time -
                //CR100-BatchAdjustCostItems +
                field("Batch Adj. Cost Error Email"; Rec."Batch Adj. Cost Error Email")
                {
                    ApplicationArea = All;
                }
                //CR100-BatchAdjustCostItems -
                //ERP-270 - CR104 - Performance improvement post cost to G/L +
                field("PostCostG/L - Commit per"; Rec."PostCostG/L - Commit per")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies number of value entries to be posted and comitted in a batch job';
                }
                //ERP-270 - CR104 - Performance improvement post cost to G/L -

            }
            //- CR029
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Item Category - Grooming"; Rec."Item Category - Grooming")
                {
                    ApplicationArea = All;
                }
                field("Item Category - DIY"; Rec."Item Category - DIY")
                {
                    ApplicationArea = All;
                }
                field("Item Category - Charity"; Rec."Item Category - Charity")
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
        }
    }

    var

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}