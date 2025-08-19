codeunit 50364 "GXL EDI Error Management"
{
    trigger OnRun()
    begin
    end;

    var
        ErrorMessage: Text;

    [Scope('OnPrem')]
    procedure SetErrorMessage(ErrorMessageNew: Text)
    begin
        ErrorMessage := ErrorMessageNew;
    end;

    [Scope('OnPrem')]
    procedure ShowErrorMessage()
    begin
        MESSAGE(ErrorMessage);
    end;

    [Scope('OnPrem')]
    procedure ThrowErrorMessage()
    begin
        ERROR(ErrorMessage);
    end;
}

