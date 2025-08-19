tableextension 50152 "GXL Store Group Setup" extends "LSC Store Group Setup"
{
    fields
    {
        field(50150; "GXL ECS UID"; Integer)
        {
            Caption = 'ECS UID';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store Group"."GXL ECS UID" where(Code = field("Store Group")));
            Editable = false;
        }
    }

}