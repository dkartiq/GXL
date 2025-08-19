/// <summary>
/// TableExtension GXL Division (ID 50170) extends Record LSC Division.
/// </summary>
tableextension 50170 "GXL Division" extends "LSC Division"
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