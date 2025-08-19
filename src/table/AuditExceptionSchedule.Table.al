table 50378 "GXL Audit Exception Schedule"
{
    Caption = 'Audit Exception Schedule';

    fields
    {
        field(1; "Week Day"; Option)
        {
            Caption = 'Week Day';
            OptionCaption = 'Monday,Tuesday,Wednseday,Thrusday,Friday,Saturday,Sunday';
            OptionMembers = Monday,Tuesday,Wednseday,Thrusday,Friday,Saturday,Sunday;
        }
        field(2; "Start Time"; Time)
        {
            Caption = 'Start Time';
        }
        field(3; "End Time"; Time)
        {
            Caption = 'End Time';
        }
    }

    keys
    {
        key(Key1; "Week Day", "Start Time", "End Time")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

