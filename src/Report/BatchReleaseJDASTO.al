report 50038 "GXL Batch Release JDA STO"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Transfer Header"; "Transfer Header")
        {
            trigger OnPreDataItem()
            begin

                IF GUIALLOWED THEN BEGIN

                    Window.OPEN(Text001 + STRSUBSTNO(Text002) + Text004
                                + Text003);
                    TotalRecords := COUNT;
                END
            end;

            trigger OnAfterGetRecord()
            var
                RsLocation: Record Location;
                TransHeader: Record "Transfer Header";
                ReleaseTranDocument: Codeunit "Release Transfer Document";
                TransLine: Record "Transfer Line";
            begin

                IF GUIALLOWED THEN BEGIN
                    Counter += 1;
                    Window.UPDATE(1, "No.");
                    Window.UPDATE(2, ROUND(Counter / TotalRecords * 10000, 1));
                END;

                TransHeader.RESET;
                TransHeader.GET("No.");

                TransLine.SETRANGE("Document No.", "No.");
                TransLine.SETFILTER(Quantity, '<>0');
                IF NOT TransLine.FINDFIRST THEN
                    CurrReport.SKIP;


                IF Status <> Status::Released THEN BEGIN
                    ReleaseTranDocument.RUN(TransHeader);

                    // >> PSEM.01
                    SuccessCounter += 1;
                    COMMIT;
                END;
                // << PSSC.00
            end;

            trigger OnPostDataItem()
            begin
                IF GUIALLOWED THEN
                    Window.CLOSE;

                IF SuccessCounter > 0 THEN BEGIN
                    IF SuccessCounter > 1 THEN
                        MESSAGE(Text001, FORMAT(SuccessCounter), 's.')
                    ELSE
                        MESSAGE(Text001, FORMAT(SuccessCounter), '.');
                END;
            end;
        }
    }


    var
        SendingBehaviour: Option ,"Do Not Prompt User","Prompt User";
        SuccessCounter: Integer;
        Window: Dialog;
        TotalRecords: Integer;
        Counter: Integer;
        Text001: Label 'Release Transfer Order...\\';
        Text002: Label 'Processing Transfer Order %1';
        Text003: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text004: Label '#1###########\\';
        Text005: Label 'The Document Type %1 is not allowed.';
        Text006: Label 'You must select a Document Type filter.';
}