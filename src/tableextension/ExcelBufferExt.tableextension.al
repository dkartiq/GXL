// 001  18.07.2025  BY   HP2-Sprint3-Changes HAR2-69
tableextension 50618 "GXL Excel Buffer Ext" extends "Excel Buffer"
{
    procedure GetCellValue(RowNoP: Integer; ColumnNoP: Integer): Text
    var
        ExcelBuffer: Record "Excel Buffer";
    begin
        IF ExcelBuffer.GET(RowNoP, ColumnNoP) THEN
            EXIT(ExcelBuffer."Cell Value as Text");
    end;

}