codeunit 50358 "GXL Job Queue Entry Management"
{

    trigger OnRun()
    begin
        CASE ProcessWhich OF
            ProcessWhich::"3PL File": 
                if APILogIsSet then begin
                    ProcessThreePLFileForAPI();
                    // We dont need to run the below function from the API as this is run via the Job Q
                    //Report.Run(report::"Import Location Files for API",false,false);
                end
                else
                    ProcessThreePLFile();
            ProcessWhich::"Vendor File":
                ProcessVendorFile();
            ELSE
                EXIT;
        END;
    end;

    var
        RecRef: RecordRef;
        ProcessWhich: Option " ","3PL File","Vendor File";
        APILog: Record "API Message Log";
        APILogIsSet: Boolean;
        FilePath: Text;
        FileName: Text;

    [Scope('OnPrem')]
    procedure SetOptions(NewProcessWhich: Option " ","3PL File","Vendor File"; NewRecRef: RecordRef; NewFilePath: Text; NewFileName: Text)
    begin
        ProcessWhich := NewProcessWhich;
        RecRef := NewRecRef;
        FilePath := NewFilePath;
        FileName := NewFileName;
    end;

    [Scope('OnPrem')]
    procedure SetOptionsForAPILog(NewProcessWhich: Option " ","3PL File","Vendor File"; InAPILog: Record "API Message Log")
    begin
        ProcessWhich := NewProcessWhich;
        APILog.Get(InAPILog."Entry No.");
        APILog.SetRecFilter();
        APILog.FindFirst();
        APILogIsSet := true;
        
        APILog.TestField("API Type");
        APILog.TestField("Location Code");
    end;

    procedure CheckAPILogIsSet()
    begin
        if not APILogIsSet then
            Error('The Global Variable API Messge Log is not Initiallised!');
    end;

    procedure CheckPaylodBlobHasValue()
    begin
        APILog.CalcFields("API Payload");
        IF not APILog."API Payload".HasValue then
            Error('API Message Log Payload Blob has no Value');
    end;

    ///<Summary>
    //Import 3PL files
    //XML port number is based on the file name
    ///</Summary>
    local procedure ProcessThreePLFile()
    var
        Location: Record Location;
        WHDataMgt: Codeunit "GXL WH Data Management";
        UnderScorePosition: Integer;
        XMLPortID: Integer;
        XMLPortTxt: Text;
    begin
        UnderScorePosition := STRPOS(FileName, '_');

        IF UnderScorePosition = 0 THEN
            EXIT;

        XMLPortTxt := COPYSTR(FileName, 1, (UnderScorePosition - 1));

        IF XMLPortTxt = '' THEN
            EXIT;

        EVALUATE(XMLPortID, XMLPortTxt);

        RecRef.SETTABLE(Location);

        IF NOT WHDataMgt.InboundFileCheck(Location.Code, XMLPortID) THEN
            EXIT;

        IF NOT EXISTS(FilePath + FileName) THEN
            EXIT;

        WHDataMgt.SetStorereason(Location.Code);
        WHDataMgt.Load3PLFile(XMLPortID, FilePath + FileName);
    end;

    local procedure ProcessThreePLFileForAPI()
    var
        Location: Record Location;
        WHDataMgt: Codeunit "GXL WH Data Management";
        UnderScorePosition: Integer;
        XMLPortID: Integer;
        XMLPortTxt: Text;
    begin
        CheckAPILogIsSet();
        CheckPaylodBlobHasValue();

        XMLPortID := APILog.GetRelatedXMLPortID();
        if XMLPortID = 0 then
            Error('There is no XML Port defined for API Type (%1) and API Source (%2) combination', APILog."API Type", APILog."API Source");

        Location.Get(APILog."Location Code");

        WHDataMgt.SetStorereason(Location.Code);
        WHDataMgt.SetAPILogEntry(APILog);
        WHDataMgt.Load3PLFileForAPIMsgLog(XMLPortID);
    end;

    ///<Summary>
    //Import vendor files
    //XML port number is based on the file name
    ///</Summary>
    local procedure ProcessVendorFile()
    var
        Vendor: Record Vendor;
        WHDataMgt: Codeunit "GXL WH Data Management";
        UnderScorePosition: Integer;
        XMLPortID: Integer;
        XMLPortTxt: Text;
    begin
        UnderScorePosition := STRPOS(FileName, '_');

        IF UnderScorePosition = 0 THEN
            EXIT;

        XMLPortTxt := COPYSTR(FileName, 1, (UnderScorePosition - 1));

        IF XMLPortTxt = '' THEN
            EXIT;

        EVALUATE(XMLPortID, XMLPortTxt);

        RecRef.SETTABLE(Vendor);

        IF NOT InboundFileCheck(Vendor."No.", XMLPortID, 0) THEN
            EXIT;

        IF NOT EXISTS(FilePath + FileName) THEN
            EXIT;

        WHDataMgt.LoadVendorFile(XMLPortID, FilePath + FileName);
    end;

    procedure InboundFileCheck(p_Code: Code[20]; XmlPortID: Integer; Type: Option " ",SD,WH,XD,FT,Confirmation,Invoice,"3pl",ASN): Boolean
    var
        _recFileSetup: Record "GXL 3Pl File Setup";
    begin
        _recFileSetup.RESET();
        _recFileSetup.SETRANGE(Code, p_Code);
        _recFileSetup.SETRANGE(Direction, _recFileSetup.Direction::Inbound);
        _recFileSetup.SETRANGE("XML Port", XmlPortID);

        //_recFileSetup.SETRANGE(_recFileSetup.Type, Type);

        //_recFileSetup.SETRANGE( _recFileSetup."Table ID",38);
        IF not _recFileSetup.IsEmpty() THEN
            EXIT(TRUE);

        EXIT(FALSE);
    end;
}

