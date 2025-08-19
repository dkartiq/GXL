pageextension 50151 "GXL Store Groups" extends "LSC Store Groups"
{
    layout
    {
        addafter("Distribution Subgroup Code")
        {
            field("GXL ECS UID"; Rec."GXL ECS UID")
            {
                ApplicationArea = All;
                BlankZero = true;
            }
        }
    }

    actions
    {
    }

}