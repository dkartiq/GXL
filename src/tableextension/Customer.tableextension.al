tableextension 50016 "GXL Customer" extends Customer
{
    fields
    {
        field(50350; "GXL Email To"; Option)
        {
            Caption = 'Email To';
            DataClassification = CustomerContent;
            OptionMembers = Customer,Contact,"Use Contact if no Email","Both Contact & Customer";
        }
    }
}