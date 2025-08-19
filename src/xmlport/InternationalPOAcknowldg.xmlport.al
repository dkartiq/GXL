xmlport 50088 "GXL International PO Acknowldg"
{
    Direction = Import;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Caption = 'International PO Acknowldgment';
    schema
    {
        textelement(InternationalPOAcknowledgement)
        {
            MaxOccurs = Once;
            textelement(OrderNumber)
            {

                trigger OnAfterAssignVariable()
                begin
                    POAck."Purchase Order No." := OrderNumber;
                end;
            }
            textelement(OrderVersion)
            {

                trigger OnAfterAssignVariable()
                begin
                    Evaluate(POAck."Order Version No.", OrderVersion);
                end;
            }
            textelement(OrderProcessedDate)
            {

                trigger OnAfterAssignVariable()
                var
                    DD: Integer;
                    MM: Integer;
                    YYYY: Integer;
                begin
                    // Expected format yyyy-mm-dd
                    if (OrderProcessedDate <> '') and
                       (StrLen(OrderProcessedDate) = 10)
                    then begin
                        if (Evaluate(DD, CopyStr(OrderProcessedDate, 9, 2))) and
                           (Evaluate(MM, CopyStr(OrderProcessedDate, 6, 2))) and
                           (Evaluate(YYYY, CopyStr(OrderProcessedDate, 1, 4)))
                        then
                            POAck."Order Processing Date" := DMY2Date(DD, MM, YYYY);
                    end;

                    POAck."No." := POAckNo;
                    POAck."EDI File Log Entry No." := EDIFileLogEntryNo;
                    POAck.Insert();
                end;
            }

            trigger OnAfterAssignVariable()
            begin
                POAck.Init();
            end;
        }
    }


    trigger OnPreXmlPort()
    begin
        POAckNo := NoSeriesMgt.GetNextNo(GetNoSeriesCode(), Today(), true);
    end;

    var
        POAck: Record "GXL International PO Acknowld";
        EDISetup: Record "GXL Integration Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        POAckNo: Code[20];
        EDIFileLogEntryNo: Integer;

    [Scope('OnPrem')]
    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        EDISetup.Get();
        exit(EDISetup."Intl. PO Ack. No. Series");
    end;
}

