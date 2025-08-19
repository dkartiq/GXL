table 50070 "RecPort"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Description; Text[200])
        {
            DataClassification = ToBeClassified;

        }
    }
    keys
    {
        key(PK; Description)
        {
            Clustered = true;
        }
    }
}