tableextension 50015 "GXL Unit of Measure" extends "Unit of Measure"
{
    fields
    {
        field(50350; "GXL JDA UOM Code"; Code[10])
        {
            Caption = 'JDA UOM Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL JDA UOM Setup";
        }
    }
    procedure GetUOMCode(UomCode: Code[10]; JDAUom: Code[10]): Code[10]
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        IF (UomCode = '') AND (JDAUom <> '') THEN BEGIN
            UnitofMeasure.RESET();
            UnitofMeasure.SETRANGE("GXL JDA UOM Code", JDAUom);
            UnitofMeasure.SETFILTER(Code, '<>%1', '');
            IF UnitofMeasure.FINDFIRST() THEN
                EXIT(UnitofMeasure.Code);
        END ELSE
            IF (UomCode <> '') AND (JDAUom = '') THEN BEGIN
                UnitofMeasure.RESET();
                UnitofMeasure.SETRANGE(Code, UomCode);
                UnitofMeasure.SETFILTER("GXL JDA UOM Code", '<>%1', '');
                IF UnitofMeasure.FINDFIRST() THEN
                    EXIT(UnitofMeasure."GXL JDA UOM Code");
            END;

        EXIT('');
    end;
}