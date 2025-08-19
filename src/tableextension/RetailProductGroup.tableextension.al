tableextension 50172 "GXL Retail Product Group" extends "LSC Retail Product Group"
{
    fields
    {
        field(50000; "GXL MPL Factor"; Integer)
        {
            Caption = 'MPL Factor';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                UpdateMPLFac: Report "GXL Update MPL Factor";
            begin
                CLEAR(UpdateMPLFac);
                UpdateMPLFac.UseRequestPage(false);
                UpdateMPLFac.SetCallFrom(1, xRec."GXL MPL Factor", Rec."GXL MPL Factor", Code);
                UpdateMPLFac.RunModal();
            end;
        }
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