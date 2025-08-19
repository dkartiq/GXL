pageextension 50152 "GXL Store Group Setup" extends "LSC Store Group Setup"
{
    layout
    {
        addafter(Level)
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