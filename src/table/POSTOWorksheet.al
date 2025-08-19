table 50078 "PO STO Worksheet"
{
    // //CS 05/09/14 added validation for positive qty
    // 
    // //-- SR11766 16/03/2015 jsr pv00.01
    //   SCT-1255 Replenish flag
    //   Added condition to only check on replenish flag based on Product Status
    // 
    // MCS1.29 30-08-16 SSO
    //   Jira SCT-1416
    //   Removed check on SKU."Replenish flag". Same done in SC Staging Worksheet.

    LookupPageID = "PO STO Worksheet";

    fields
    {
        field(1; "Batch Code"; Code[20])
        {
        }
        field(2; Line; Integer)
        {
        }
        field(4; "To-Location"; Code[10])
        {
            Caption = 'To-Location';

            trigger OnValidate()
            begin
                IF recLocation.GET("To-Location") THEN BEGIN
                    rec."Store Name" := recLocation.Name;
                    IF (ILC <> '') AND ("To-Location" <> '') THEN
                        CheckSku;

                END ELSE BEGIN
                    SetError(text0001);
                END;
            end;
        }
        field(5; ILC; Code[20])
        {
            Caption = 'ILC';
            Editable = true;

            trigger OnValidate()
            begin
                //Get Item & UOM & Description & SOURCE OF SUPPLY Check
                IF _recItem.GET(ILC) THEN BEGIN
                    Description := _recItem.Description;
                    "Item UOM Code" := _recItem."Base Unit of Measure";
                    IF (ILC <> '') AND ("To-Location" <> '') THEN
                        CheckSku;
                END ELSE
                    SetError(text0002);
            end;
        }
        field(6; Description; Text[50])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(7; "Item UOM Code"; Code[10])
        {
            Caption = 'Item Unit of Measure Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD(ILC));
        }
        field(9; "Order Qty"; Decimal)
        {

            trigger OnValidate()
            begin
                CheckItemMinOrderMultiple;

                //CS 05/09/14 added validation for positive qty
                IF "Order Qty" <= 0 THEN
                    SetError(Text0010);
            end;
        }
        field(50212; "Source of Supply"; Option)
        {
            Caption = 'Source of Supply';
            Description = 'PSSC.00';
            OptionCaption = 'SD,WH,XD,FT';
            OptionMembers = SD,WH,XD,FT;

            trigger OnValidate()
            begin
                // >> PSSC.00
                IF "Source of Supply" <> _recSKu."GXL Source of Supply" THEN
                    SetError(text0006);
                // << PSSC.00
            end;
        }
        field(50213; "Load Date"; Date)
        {
        }
        field(50214; "Error Description"; Text[250])
        {
        }
        field(50215; "Pass Flag"; Boolean)
        {
        }
        field(50216; "User Id"; Text[100])
        {
        }
        field(50217; "Store Name"; Text[50])
        {
        }
        field(50218; "Distributor Number"; Code[20])
        {
        }
        field(50219; "Warehouse Supplier"; Code[10])
        {
            Caption = 'Warehouse Supplier';
        }
        field(50220; "XRef Document Number"; Code[20])
        {
        }
        field(50221; "XRef Type"; Option)
        {
            OptionMembers = Purchase,STO;
        }
        field(50222; "PO Number"; Code[20])
        {
            Caption = 'PO Number';
        }
        field(50223; "PO Line Number"; Integer)
        {
        }

        field(50224; "Load Sequence"; Text[10])
        {
        }

        field(11; "Worksheet Template Name"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Worksheet Template Name';
            TableRelation = "Req. Wksh. Template";
        }
        field(12; "Journal Batch Name"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Batch Name';
            TableRelation = "Requisition Wksh. Name".Name WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"));
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Journal Batch Name", Line)
        {
            Clustered = true;
        }
        key(Key2; "Batch Code", "Source of Supply", "Distributor Number", "To-Location")
        {
        }
        key(Key3; "Batch Code", "Source of Supply", "Distributor Number", "Warehouse Supplier", "To-Location")
        {
        }
        key(Key4; "Pass Flag", "Batch Code", "Source of Supply", "Distributor Number", "Warehouse Supplier", ILC)
        {
            SumIndexFields = "Order Qty";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Load Date" := WORKDATE;
        "User Id" := USERID;
    end;

    trigger OnModify()
    begin
        "Pass Flag" := FALSE;
    end;

    var
        _recPOH: Record "Purchase Header";
        _recPL: Record "Purchase Line";
        TotalLineQtyOrdered: Decimal;
        text0001: Label 'The Location does not exist';
        text0002: Label 'The Item does not exist';
        text0003: Label 'The Order must be Flow through or X-Dock';
        recLocation: Record Location;
        text0004: Label 'The sku does not exist';
        text0005: Label 'You cannot transfer more than what is ordered';
        text0006: Label 'Source of Supply is not same';
        text0007: Label 'You cannot transfer to the receiving location';
        _recItem: Record Item;
        _recSKu: Record "Stockkeeping Unit";
        Text0008: Label '%1 for %2 should be ordered in multiples of %3 !';
        Text0009: Label '%1 for %2 should be ordered should be greater than 0 !';
        Text0010: Label 'Quantity should be positive';
        OpenFromBatch: Boolean;
        Text002: Label 'RECURRING';
        Text99000000: Label '%1 Worksheet';
        Text99000001: Label 'Recurring Worksheet';


    procedure GetPurchaseHeader()
    begin
    end;

    procedure GetPurchaseLine()
    begin
    end;

    procedure GetLocationCode()
    begin
    end;

    procedure CheckQtyRemaining(PLQTY: Decimal)
    begin
    end;

    procedure SetError(ErrorText: Text[100])
    begin
        IF "Error Description" <> '' THEN BEGIN
            IF STRPOS("Error Description", ErrorText) = 0 THEN
                "Error Description" := "Error Description" + ':' + ErrorText
        END ELSE
            "Error Description" := ErrorText;
        "Pass Flag" := FALSE;
    end;

    procedure CheckSku(): Decimal
    var
        _lclrecPTL: Record "PO STO Worksheet";
        TotalCount: Decimal;
    begin
        _recSKu.RESET;
        _recSKu.SETRANGE("Location Code", "To-Location");
        _recSKu.SETRANGE("Item No.", ILC);
        IF _recSKu.FINDFIRST THEN BEGIN
            IF "Source of Supply" <> "Source of Supply"::WH THEN
                "Distributor Number" := _recSKu."GXL Distributor Number";
            IF "Source of Supply" <> "Source of Supply"::SD THEN
                "Warehouse Supplier" := _recSKu."GXL Source of Supply Code";
        END;
    end;

    local procedure CheckItemMinOrderMultiple()
    var
        Confirmed: Boolean;
    begin
        // >> PSSC.00
        _recSKu.RESET;
        _recSKu.SETRANGE("Location Code", "To-Location");
        _recSKu.SETRANGE("Item No.", ILC);
        IF _recSKu.FINDFIRST THEN BEGIN

            IF "Order Qty" = 0 THEN BEGIN
                SetError(Text0009);
            END ELSE BEGIN

                //_recSKu.CALCFIELDS("GXL New Ranging Flag");

                IF _recSKu."GXL New Ranging Flag" = FALSE THEN
                    SetError('is not ranged');

                //>> MCS1.29
                /*#
                //>> pv00.01
                IF (_recSKu."Product Status" >= _recSKu."Product Status"::"Discontinued-WH only") THEN
                //<< pv00.01
                  IF _recSKu."Replenish Flag"=FALSE THEN
                    SetError('is not Replenish');
                #*/
                //<< MCS1.29

                _recSKu.CALCFIELDS("GXL Warehouse SKU");
                IF (_recSKu."GXL Warehouse SKU") THEN BEGIN
                    IF (_recSKu."GXL Source of Supply" IN [_recSKu."GXL Source of Supply"::FT, _recSKu."GXL Source of Supply"::XD]) THEN
                        SetError("To-Location" + ' must be a store loction');

                END;
                IF (_recSKu."GXL Warehouse SKU")
                 AND (_recSKu."GXL Source of Supply" IN [_recSKu."GXL Source of Supply"::FT, _recSKu."GXL Source of Supply"::WH]) THEN BEGIN
                    IF _recSKu."GXL Order Pack (OP)" <> 0 THEN BEGIN
                        IF "Order Qty" MOD _recSKu."GXL Order Pack (OP)" <> 0 THEN
                            SetError(STRSUBSTNO(Text0008, FIELDCAPTION("Order Qty"), _recSKu."Item No.", _recSKu."GXL Order Pack (OP)"));
                    END;
                END ELSE BEGIN
                    IF _recSKu."GXL Order Multiple (OM)" <> 0 THEN
                        IF "Order Qty" MOD _recSKu."GXL Order Multiple (OM)" <> 0 THEN
                            SetError(STRSUBSTNO(Text0008, FIELDCAPTION("Order Qty"), _recSKu."Item No.", _recSKu."GXL Order Multiple (OM)"));
                END;
            END;
        END
        ELSE
            SetError(text0004);
        // << PSSC.00

    end;

    procedure OpenJnl(VAR CurrentJnlBatchName: Code[10]; VAR POSTOWksht: Record "PO STO Worksheet")
    begin
        CheckTemplateName(POSTOWksht.GETRANGEMAX("Worksheet Template Name"), CurrentJnlBatchName);
        POSTOWksht.FILTERGROUP := 2;
        POSTOWksht.SETRANGE("Journal Batch Name", CurrentJnlBatchName);
        POSTOWksht.FILTERGROUP := 0;
    end;

    LOCAL procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; VAR CurrentJnlBatchName: Code[10])
    var
        ReqWkshName: Record "Requisition Wksh. Name";
        Text004: Label 'DEFAULT';
        Text005: Label 'Default Journal';
    Begin
        ReqWkshName.SETRANGE("Worksheet Template Name", CurrentJnlTemplateName);
        IF NOT ReqWkshName.GET(CurrentJnlTemplateName, CurrentJnlBatchName) THEN BEGIN
            IF NOT ReqWkshName.FINDFIRST THEN BEGIN
                ReqWkshName.INIT;
                ReqWkshName."Worksheet Template Name" := CurrentJnlTemplateName;
                ReqWkshName.Name := Text004;
                ReqWkshName.Description := Text005;
                ReqWkshName.INSERT(TRUE);
                COMMIT;
            END;
            CurrentJnlBatchName := ReqWkshName.Name
        END;
    End;

    procedure WkshTemplateSelection(PageID: Integer; RecurringJnl: Boolean; TemplateType: Enum "Req. Worksheet Template Type"; var POSTOWorksheet: Record "PO STO Worksheet"; var JnlSelected: Boolean)
    var
        ReqWkshTemplate: Record "Req. Wksh. Template";
    begin
        JnlSelected := true;

        ReqWkshTemplate.Reset();
        ReqWkshTemplate.SetRange("Page ID", PageID);
        ReqWkshTemplate.SetRange(Recurring, RecurringJnl);
        ReqWkshTemplate.SetRange(Type, TemplateType);
        case ReqWkshTemplate.Count() of
            0:
                begin
                    ReqWkshTemplate.Init();
                    ReqWkshTemplate.Recurring := RecurringJnl;
                    ReqWkshTemplate.Type := TemplateType;
                    if not RecurringJnl then begin
                        ReqWkshTemplate.Name := CopyStr(Format(TemplateType), 1, MaxStrLen(ReqWkshTemplate.Name));
                        ReqWkshTemplate.Description := StrSubstNo(Text99000000, Format(TemplateType));
                    end else begin
                        ReqWkshTemplate.Name := Text002;
                        ReqWkshTemplate.Description := Text99000001;
                    end;
                    ReqWkshTemplate.Validate("Page ID");
                    ReqWkshTemplate.Insert();
                    Commit();
                end;
            1:
                ReqWkshTemplate.FindFirst();
            else
                JnlSelected := PAGE.RunModal(0, ReqWkshTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            POSTOWorksheet.FilterGroup := 2;
            POSTOWorksheet.SetRange("Worksheet Template Name", ReqWkshTemplate.Name);
            POSTOWorksheet.FilterGroup := 0;
            if OpenFromBatch then begin
                POSTOWorksheet."Worksheet Template Name" := '';
                PAGE.Run(ReqWkshTemplate."Page ID", POSTOWorksheet);
            end;
        end;
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; var POSTOWksht: Record "PO STO Worksheet")
    begin
        POSTOWksht.FilterGroup := 2;
        POSTOWksht.SetRange("Journal Batch Name", CurrentJnlBatchName);
        POSTOWksht.FilterGroup := 0;
        if POSTOWksht.Find('-') then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var POSTOWksht: Record "PO STO Worksheet")
    var
        ReqWkshName: Record "Requisition Wksh. Name";
    begin
        Commit();
        ReqWkshName."Worksheet Template Name" := POSTOWksht.GetRangeMax("Worksheet Template Name");
        ReqWkshName.Name := POSTOWksht.GetRangeMax("Journal Batch Name");
        ReqWkshName.FilterGroup(2);
        ReqWkshName.SetRange("Worksheet Template Name", ReqWkshName."Worksheet Template Name");
        ReqWkshName.FilterGroup(0);
        if PAGE.RunModal(0, ReqWkshName) = ACTION::LookupOK then begin
            CurrentJnlBatchName := ReqWkshName.Name;
            SetName(CurrentJnlBatchName, POSTOWksht);
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; var POSTOWksht: Record "PO STO Worksheet")
    var
        ReqWkshName: Record "Requisition Wksh. Name";
    begin
        ReqWkshName.Get(POSTOWksht.GetRangeMax("Worksheet Template Name"), CurrentJnlBatchName);
    end;

    procedure ExportPOTOs(TemplateName: Code[10]; BatchName: Code[10])
    var
        POTOWorksheet: Record "PO STO Worksheet";
        ExcelBuffer: Record "Excel Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        Outstream: OutStream;
        Instream: InStream;
        DateTime: Text;
        FileName: Text;

    begin
        POTOWorksheet.SetRange("Worksheet Template Name", TemplateName);
        POTOWorksheet.SetRange("Journal Batch Name", BatchName);
        if Not POTOWorksheet.FindSet() then
            exit;

        ExcelBuffer.DeleteAll();
        ExcelBuffer.AddColumn('Template', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(POTOWorksheet."Worksheet Template Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Batch', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(POTOWorksheet."Journal Batch Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Batch Code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('ILC', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('To-Location', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Quantity', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Load Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn('Load sequence', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Line No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);

        repeat
            ExcelBuffer.NewRow();
            ExcelBuffer.AddColumn(POTOWorksheet."Batch Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(POTOWorksheet.ILC, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(POTOWorksheet."To-Location", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(POTOWorksheet."Order Qty", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(POTOWorksheet."Load Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
            ExcelBuffer.AddColumn(POTOWorksheet."Load Sequence", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(POTOWorksheet.Line, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        until POTOWorksheet.Next() = 0;

        ExcelBuffer.CreateNewBook('PO/TO Worksheet');
        ExcelBuffer.WriteSheet('PO/TO Worksheet', '', '');
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();

        TempBlob.CreateOutStream(Outstream);
        ExcelBuffer.SaveToStream(Outstream, true);
        DateTime := Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hour,2><Minute,2><Second,2>');
        FileName := StrSubstNo('PO/TO Worksheet_%1_%2_%3.xlsx', POTOWorksheet."Worksheet Template Name", POTOWorksheet."Journal Batch Name", DateTime);
        TempBlob.CreateInStream(Instream);
        DownloadFromStream(Instream, '', '', '', FileName);
    end;

    procedure ImportPOTO(POTOWorksheet: Record "PO STO Worksheet"; Selection: Integer)
    var
        ExcelBuffer: Record "Excel Buffer";
        FileName: Text;
        FileInstream: InStream;
        Dialog: Dialog;
        LineNo: Integer;
        LineNo2: Integer;
        LastRow: Integer;
        ExcelRow: Integer;
        BatchName: Code[10];
        TempName: Code[10];
        ImportLbl: Label 'PO/TO Worksheet imported Successfully';

    begin
        case Selection of
            1:
                POTOWorksheet."Source of Supply" := POTOWorksheet."Source of Supply"::SD;
            2:
                POTOWorksheet."Source of Supply" := POTOWorksheet."Source of Supply"::WH;
            3:
                POTOWorksheet."Source of Supply" := POTOWorksheet."Source of Supply"::XD;
            4:
                POTOWorksheet."Source of Supply" := POTOWorksheet."Source of Supply"::FT;
        end;
        ExcelBuffer.DeleteAll();
        Clear(ExcelBuffer);
        Dialog.Open('Select Excel file to import...');
        UploadIntoStream('Import PO/TO Workesheet', '', '', FileName, FileInstream);

        ExcelBuffer.OpenBookStream(FileInstream, 'PO/TO Worksheet');
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetRange("Column No.", 1);
        ExcelBuffer.FindLast;
        LastRow := ExcelBuffer."Row No.";
        ExcelBuffer.Reset();
        BatchName := ExcelBuffer.GetCellValue(1, 4);
        Tempname := ExcelBuffer.GetCellValue(1, 2);
        Evaluate(LineNo, ExcelBuffer.GetCellValue(ExcelRow, 7));

        for ExcelRow := 4 to LastRow Do begin
            IF NOt POTOWorksheet.GET(BatchName, TempName, Lineno) Then Begin
                POTOWorksheet.Init();
                POTOWorksheet.Validate("Journal Batch Name", BatchName);
                POTOWorksheet.Validate("Worksheet Template Name", TempName);
                POTOWorksheet.Validate(Line, GetPOTOLineNo(POTOWorksheet."Journal Batch Name", POTOWorksheet."Worksheet Template Name"));
                POTOWorksheet.Insert(True);
            End;


            if (POTOWorksheet."Batch Code" <> ExcelBuffer.GetCellValue(ExcelRow, 1)) then
                POTOWorksheet.Validate("Batch Code", ExcelBuffer.GetCellValue(ExcelRow, 1));
            if (POTOWorksheet.ILC <> ExcelBuffer.GetCellValue(ExcelRow, 2)) then
                POTOWorksheet.Validate(ILC, ExcelBuffer.GetCellValue(ExcelRow, 2));
            if (POTOWorksheet."To-Location" <> ExcelBuffer.GetCellValue(ExcelRow, 3)) then
                POTOWorksheet.Validate("To-Location", ExcelBuffer.GetCellValue(ExcelRow, 3));
            Evaluate(POTOWorksheet."Order Qty", ExcelBuffer.GetCellValue(ExcelRow, 4));
            Evaluate(POTOWorksheet."Load Date", ExcelBuffer.GetCellValue(ExcelRow, 5));
            if (POTOWorksheet."Load Sequence" <> ExcelBuffer.GetCellValue(ExcelRow, 6)) then
                POTOWorksheet.Validate("Load Sequence", ExcelBuffer.GetCellValue(ExcelRow, 6));
            POTOWorksheet.Modify(true);

        end;
        ExcelBuffer.Reset();

        Message(ImportLbl);
    end;

    local procedure GetPOTOLineNo(BatchNameP: Code[20]; TemplateNameP: Code[20]): Integer
    var
        POTOWorksheet: Record "PO STO Worksheet";
    begin
        POTOWorksheet.SetRange("Journal Batch Name", BatchNameP);
        POTOWorksheet.SetRange("Worksheet Template Name", TemplateNameP);
        if POTOWorksheet.FindLast() then
            exit(POTOWorksheet.Line + 10000);

        exit(10000);
    end;
}

