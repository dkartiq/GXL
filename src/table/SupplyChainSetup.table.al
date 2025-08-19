table 50002 "GXL Supply Chain Setup"
{
    /*Change Log
        CR029: Average Cost trapping: New field to archive logging before
        
        CR100-BatchAdjustCostItems: Added field "Batch Adj. Cost Error Email"

        PS-2400 15-02-2021 LP
            Added fields: "Item Category - Grooming", "Item Category - DYI", "Item Category - Charity"
        
        ERP-NAV Master Data Management: 
            New field "Ranging is Active" to specify if MIM is using the actual ranging function or just assume all products are ramged
    */
    Caption = 'Supply Chain Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Illegal Product Range Email"; Text[80])
        {
            Caption = 'Illegal Product Range Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        //+ CR029
        field(3; "AvgCostLog Archive Before"; Integer)
        {
            Caption = 'Average Cost Change Log - Archive Before';
            DataClassification = CustomerContent;
        }
        //- CR029
        //PS-2400+
        field(4; "Item Category - Grooming"; Code[20])
        {
            Caption = 'Item Category - Grooming';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
        }
        field(5; "Item Category - DIY"; Code[20])
        {
            Caption = 'Item Category - DIY';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
        }
        field(6; "Item Category - Charity"; Code[20])
        {
            Caption = 'Item Category - Charity';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
        }
        //PS-2400-
        //ERP-NAV Master Data Management +
        field(10; "Ranging Is Active"; Boolean)
        {
            Caption = 'Ranging is Active';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management -
        //CR100-BatchAdjustCostItems +
        field(50040; "Batch Adj. Cost Error Email"; Text[80])
        {
            Caption = 'Batch Adj. Cost Error Email';
            DataClassification = CustomerContent;
        }
        //CR100-BatchAdjustCostItems -
        //ERP-278-Duplicate average cost change log +
        field(50041; "Adjust Cost Items - Commit per"; Integer)
        {
            Caption = 'Adjust Cost Items - Commit per';
            DataClassification = CustomerContent;
        }
        field(50042; "Enable Average Cost Change Log"; Boolean)
        {
            Caption = 'Enable Average Cost Change Log';
            DataClassification = CustomerContent;
        }
        //ERP-278-Duplicate average cost change log -
        //ERP-304-Batch Adjust cost record start/end time +
        field(50043; "Log Adjust Cost Start/End Time"; Boolean)
        {
            Caption = 'Log Adjust Cost Start/End Time';
            DataClassification = CustomerContent;
        }
        //ERP-304-Batch Adjust cost record start/end time -
        //ERP-270 - CR104 - Performance improvement post cost to G/L +
        field(50050; "PostCostG/L - Commit per"; Integer)
        {
            Caption = 'Post Cost to G/L - Commit per';
            DataClassification = CustomerContent;
        }
        // >> HP2-SPRINT2
        field(50052; "GXL Default Transportation Mode"; Code[50])
        {
            TableRelation = "GXL Transport Type";
            Caption = 'Default Transportation Mode';
        }
        // << HP2-SPRINT2
        //ERP-270 - CR104 - Performance improvement post cost to G/L -
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}