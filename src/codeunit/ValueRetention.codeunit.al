codeunit 50004 "GXL Value Retention"
{
    SingleInstance = true;

    var
        TextValue: Text;
        IntegerValue: Integer;
        ICDocNo: Code[20];
        ICTransactionNo: Integer;


    procedure ClearText()
    begin
        TextValue := '';
    end;

    procedure SetText(NewTextValue: Text)
    begin
        TextValue := NewTextValue;
    end;

    procedure GetText(): Text
    begin
        EXIT(TextValue);
    end;

    procedure ClearInteger()
    begin
        IntegerValue := 0;
    end;

    procedure SetInteger(NewIntegerValue: Integer)
    begin
        IntegerValue := NewIntegerValue;
    end;

    procedure GetInteger(): Integer
    begin
        EXIT(IntegerValue);
    end;


    //ERP-NAV Master Data Management: Automate IC Transaction +
    procedure SetICTransactions(NewDocNo: Code[20]; NewICTransNo: Integer)
    begin
        ICDocNo := NewDocNo;
        ICTransactionNo := NewICTransNo;
    end;

    procedure GetICTransactions(var NewDocNo: Code[20]; NewICTransNo: Integer)
    begin
        NewDocNo := ICDocNo;
        NewICTransNo := ICTransactionNo;
    end;
    //ERP-NAV Master Data Management: Automate IC Transaction -

}