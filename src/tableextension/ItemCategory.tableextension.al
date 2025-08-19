tableextension 50171 "GXL Item Category" extends "Item Category"
{
    fields
    {
        //Bloyal integration
        field(50170; "GXL Bloyal Date Time Modified"; DateTime)
        {
            //Internal used for Bloyal integration only. To update last datetime that specific fields being changed.
            DataClassification = CustomerContent;
            Caption = 'Bloyal Date Time Modified';
            Editable = false;
        }
    }

    keys
    {
        key(GXL_BloyalDateTimeModified; "GXL Bloyal Date Time Modified") { }

    }


}