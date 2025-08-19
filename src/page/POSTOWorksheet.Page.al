page 10016892 "PO STO Worksheet"
{
    // //CS 04/09/14 added validation for Source of supply

    PageType = List;
    SourceTable = "PO STO Worksheet";
    ApplicationArea = All;
    UsageCategory = Administration;
    layout
    {
        area(content)
        {

            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Planning;
                Caption = 'Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the record.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    Rec.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    Rec.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali();
                end;
            }

            repeater(Group)
            {
                field("Batch Code"; rec."Batch Code")
                {
                }
                field(Line; rec.Line)
                {
                }
                field("To-Location"; rec."To-Location")
                {
                }
                field(ILC; rec.ILC)
                {
                }
                field(Description; rec.Description)
                {
                }
                field("Item UOM Code"; rec."Item UOM Code")
                {
                    Caption = 'Item UOM  Code';
                }
                field("Order Qty"; rec."Order Qty")
                {
                }
                field("Load Sequence"; Rec."Load Sequence")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Load Sequence field.', Comment = '%';
                }

                field("Source of Supply"; rec."Source of Supply")
                {
                }
                field("Load Date"; rec."Load Date")
                {
                }
                field("Error Description"; rec."Error Description")
                {
                }
                field("Pass Flag"; rec."Pass Flag")
                {
                }
                field("User Id"; rec."User Id")
                {
                }
                field("Warehouse Supplier"; rec."Warehouse Supplier")
                {
                }
            }
            group(TotalRecords)
            {
                grid("Total Record Count")
                {
                    GridLayout = Columns;
                    group("Total Record")
                    {
                        group("Total Records")
                        {
                            field(TotalRecordCount; TotalRecordCount)
                            {
                                Caption = 'Total Record Count';
                                DecimalPlaces = 0 : 1;
                                Editable = false;
                                Visible = true;
                            }
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Export")
            {
                Caption = '&Export';
                Ellipsis = true;
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POTOWorksheet: Record "PO STO Worksheet";
                    BatchName: Code[10];
                    TemplateName: Code[10];
                begin
                    BatchName := Rec."Journal Batch Name";
                    TemplateName := rec."Worksheet Template Name";
                    POTOWorksheet.ExportPOTOs(TemplateName, BatchName);
                end;
            }
            Action("I&mport")
            {
                Caption = 'I&mport';
                Ellipsis = true;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POTOWorksheet: Record "PO STO Worksheet";
                    SourceOSupSln: Integer;
                    StrMenuLbl: Label 'SD,WH,XD,FT';
                begin
                    Selection := STRMENU(StrMenuLbl, 1);
                    IF Selection = 0 THEN
                        EXIT;
                    POTOWorksheet.ImportPOTO(POTOWorksheet, SourceOSupSln);
                end;
            }
            /*
            action("&Import")
            {
                Caption = '&Import';
                Ellipsis = true;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var

                begin
                    // >> PSSC.00
                    Importfile;
                    // << PSSC.00
                end;
            }*/
            action("&Validate")
            {
                Caption = '&Validate';
                Ellipsis = true;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POWkst: Record "PO STO Worksheet";
                begin
                    // >> PSSC.00
                    POWkst.RESET;
                    IF POWkst.COUNT > 0 THEN
                        POWkst.MODIFYALL("Error Description", '');

                    IF POWkst.FINDSET THEN
                        REPEAT
                            POWkst.VALIDATE("To-Location");
                            POWkst.VALIDATE(ILC);
                            POWkst.VALIDATE("Order Qty");

                            //CS 04/09/14 added validation for Source of supply
                            POWkst.VALIDATE(POWkst."Source of Supply");
                            IF (Selection <> 0) AND
                               (((POWkst."Source of Supply" = POWkst."Source of Supply"::SD) AND (Selection <> 1)) OR
                               ((POWkst."Source of Supply" = POWkst."Source of Supply"::WH) AND (Selection <> 2)) OR
                               ((POWkst."Source of Supply" = POWkst."Source of Supply"::XD) AND (Selection <> 3)) OR
                               ((POWkst."Source of Supply" = POWkst."Source of Supply"::FT) AND (Selection <> 4)))
                              THEN
                                POWkst.SetError('Source of Supply does not match the batch selection');

                            IF POWkst."Error Description" = '' THEN
                                POWkst."Pass Flag" := TRUE
                            ELSE
                                POWkst."Pass Flag" := FALSE;

                            POWkst.MODIFY;
                        UNTIL POWkst.NEXT = 0;
                    CurrPage.UPDATE(FALSE)
                    // << PSSC.00
                end;
            }
            /* 
            action("&Create Orders")
            {
                Caption = '&Create Orders';
                Ellipsis = true;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SCCreateTransferOrder: Report "50224";
                begin
                    // >> PSSC.00
                    CLEAR(SCCreateTransferOrder);
                    //SCCreateTransferOrder.SETTABLEVIEW(Rec);
                    SCCreateTransferOrder.RUNMODAL;
                    CurrPage.UPDATE(FALSE);
                    // << PSSC.00
                end;
            }
             */
        }
    }

    var
        TotalRecordCount: Decimal;
        Text000: Label 'SD,WH,XD,FT';
        Selection: Integer;
        ReqJnlManagement: Codeunit ReqJnlManagement;
        OpenedFromBatch: Boolean;
        CurrentJnlBatchName: Code[10];
        ExtendedPriceEnabled: Boolean;

    trigger OnAfterGetRecord()
    begin
        TotalRecordCount := TotalRecordCount + 1;
    end;

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        JnlSelected: Boolean;
    begin
        TotalRecordCount := 0;
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
        OpenedFromBatch := (Rec."Journal Batch Name" <> '') and (Rec."Worksheet Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := rec."Journal Batch Name";
            Rec.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        rec.WkshTemplateSelection(
            PAGE::"Req. Worksheet", false, "Req. Worksheet Template Type"::"Req.", Rec, JnlSelected);
        if not JnlSelected then
            Error('');

        Rec.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    local procedure Importfile()
    /* 
        var
            POSTOImport: XMLport "50290";
        begin
            CLEAR(POSTOImport);
            Selection := STRMENU(Text000,1);
            IF Selection = 0 THEN
              EXIT;
            CLEAR(POSTOImport);
            POSTOImport.SetSOS(Selection-1);
            POSTOImport.RUN;
            //XMLPORT.RUN(XMLPORT::"Orders Import",TRUE, TRUE , Rec);
            CurrPage.UPDATE(FALSE);
        end;
     */
    begin

    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord();
        Rec.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

}

