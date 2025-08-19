table 50001 "GXL Administration Cue"
{
    Caption = 'GXL Administration Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Job Queue Entries Until Today"; Integer)
        {
            CalcFormula = Count("Job Queue Entry" WHERE("Earliest Start Date/Time" = FIELD("Date Filter2"),
                                                         "Expiration Date/Time" = FIELD("Date Filter3")));
            Caption = 'Job Queue Entries Until Today';
            FieldClass = FlowField;
        }
        field(11; "Job Queue Entries - Ready"; Integer)
        {
            CalcFormula = Count("Job Queue Entry" WHERE(Status = CONST(Ready)));
            Caption = 'Job Queue Entries - Ready';
            FieldClass = FlowField;
        }
        field(12; "Job Queue Entries - InProcess"; Integer)
        {
            CalcFormula = Count("Job Queue Entry" WHERE(Status = CONST("In Process")));
            Caption = 'Job Queue Entries - InProcess';
            FieldClass = FlowField;
        }
        field(13; "Job Queue Entries - Error"; Integer)
        {
            CalcFormula = Count("Job Queue Entry" WHERE(Status = CONST(Error)));
            Caption = 'Job Queue Entries - Error';
            FieldClass = FlowField;
        }
        field(14; "Job Queue Entries - OnHold"; Integer)
        {
            CalcFormula = Count("Job Queue Entry" WHERE(Status = CONST("On Hold")));
            Caption = 'Job Queue Entries - OnHold';
            FieldClass = FlowField;
        }
        field(15; "Job Queue Entries - Finished"; Integer)
        {
            CalcFormula = Count("Job Queue Entry" WHERE(Status = CONST(Finished)));
            Caption = 'Job Queue Entries - Finished';
            FieldClass = FlowField;
        }
        field(16; "Job Queue Entries - OnHold T/O"; Integer)
        {
            CalcFormula = Count("Job Queue Entry" WHERE(Status = CONST("On Hold with Inactivity Timeout")));
            Caption = 'Job Queue Entries - OnHold T/O';
            FieldClass = FlowField;
        }
        field(30; "Requests to Approve"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Approver ID" = FIELD("User ID Filter"), Status = FILTER(Open)));
            Caption = 'Requests to Approve';
            FieldClass = FlowField;
        }
        field(100; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(101; "Date Filter2"; DateTime)
        {
            Caption = 'Date Filter2';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(102; "Date Filter3"; DateTime)
        {
            Caption = 'Date Filter3';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(103; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(50100; "Magento Web Order Entries"; Integer)
        {
            CalcFormula = Count("GXL Magento Web Order");
            Caption = 'Magento Web Order Entries';
            FieldClass = FlowField;
        }
        field(50101; "Magento WO Entries - Error"; Integer)
        {
            CalcFormula = Count("GXL Magento Web Order" WHERE(Status = FILTER(Error)));
            Caption = 'Magento WO Entries - Error';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

