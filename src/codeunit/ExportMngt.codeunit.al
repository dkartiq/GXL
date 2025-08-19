codeunit 50356 "GXL Export Mngt."
{
    var
        Text001Lbl: Label '<Day,2>%1<Month,2>%1<Year4>';
        Text002Lbl: Label '<Day,2>%1<Month,2>%1<Year,2>';
        Text003Lbl: Label '<Year4>%1<Month,2>%1<Day,2>';
        Text004Lbl: Label '<Year2>%1<Month,2>%1<Day,2>';
        Text005Lbl: Label '<Hours24>%1<Minutes,2>';
        Text006Lbl: Label '<Hours24>%1<Minutes,2>%1<Seconds,2>';

    procedure FormatDateValue(InputDate: Date; InputDateFormat: Option " ",DDMMYYYY,DDMMYY,YYYYMMDD,YYMMDD; InputDateSeparator: Option " ",".","/","-") InnerText: Text
    begin
        CASE InputDateFormat OF
            InputDateFormat::DDMMYYYY:
                BEGIN
                    InnerText := FORMAT(InputDate, 0, STRSUBSTNO(Text001Lbl, DELCHR(FORMAT(InputDateSeparator), '=', ' ')));
                END;
            InputDateFormat::DDMMYY:
                BEGIN
                    InnerText := FORMAT(InputDate, 0, STRSUBSTNO(Text002Lbl, DELCHR(FORMAT(InputDateSeparator), '=', ' ')));
                END;
            InputDateFormat::YYYYMMDD:
                BEGIN
                    InnerText := FORMAT(InputDate, 0, STRSUBSTNO(Text003Lbl, DELCHR(FORMAT(InputDateSeparator), '=', ' ')));
                END;
            InputDateFormat::YYMMDD:
                BEGIN
                    InnerText := FORMAT(InputDate, 0, STRSUBSTNO(Text004Lbl, DELCHR(FORMAT(InputDateSeparator), '=', ' ')));
                END;
            ELSE
                InnerText := FORMAT(InputDate);
        END;
    end;

    procedure FormatTimeValue(InputTime: Time; InputTimeFormat: Option " ",HHMM,HHMMSS; InputTimeSeparator: Option " ",".",":","-") InnerText: Text
    begin
        CASE InputTimeFormat OF
            InputTimeFormat::HHMM:
                BEGIN
                    InnerText := FORMAT(InputTime, 0, STRSUBSTNO(Text005Lbl, DELCHR(FORMAT(InputTimeSeparator), '=', ' ')));
                END;
            InputTimeFormat::HHMMSS:
                BEGIN
                    InnerText := FORMAT(InputTime, 0, STRSUBSTNO(Text006Lbl, DELCHR(FORMAT(InputTimeSeparator), '=', ' ')));
                END;
        END;
    end;
}