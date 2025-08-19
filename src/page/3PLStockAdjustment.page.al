// 001  18.03.2024 LCB-291 New field added.
page 50384 "GXL 3PL Stock Adjustment"
{
    Caption = '3PL Stock Adjustment';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GXL WH Message Lines";
    SourceTableView = SORTING("Import Type", "Document No.", "Item No.") WHERE("Import Type" = FILTER("Item Adj."));
    UsageCategory = History;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field("Error Found"; Rec."Error Found")
                {
                    ApplicationArea = All;
                }
                field("Import Type"; Rec."Import Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Qty. To Receive"; Rec."Qty. To Receive")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Error Description"; Rec."Error Description")
                {
                    ApplicationArea = All;
                }
                field("Date Imported"; Rec."Date Imported")
                {
                    ApplicationArea = All;
                }
                field("Time Imported"; Rec."Time Imported")
                {
                    ApplicationArea = All;
                }
                field("Decrease Entry No."; Format(Rec."Decrease Entry No."))
                {
                    ApplicationArea = All;
                    Caption = 'Decrease Entry No.';
                    ToolTip = 'Specifies the value of the Decrease Entry No.';
                    Editable = false;
                }
                field("Increase Entry No."; Format(Rec."Increase Entry No."))
                {
                    ApplicationArea = All;
                    Caption = 'Increase Entry No.';
                    ToolTip = 'Specifies the value of the Increase Entry No.';
                    Editable = false;
                }
                // >> GX202316 - New Change
                field("Skip Decrease"; Rec."Skip Decrease")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Skip Decrease';
                    Editable = false;
                    Visible = False;
                }
                // << GX202316 - New Change
                // >> 001 
                field("BC Reason Code"; Rec."BC Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BC Reason Code field.';
                }
                field("Mapping Exists"; Rec."Mapping Exists")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mapping Exists field.';
                }
                // << 001
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Reset Error")
                {
                    Caption = 'Reset Error';
                    Ellipsis = true;
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = ResetStatus;

                    trigger OnAction()
                    var
                        EdiMessage: Record "GXL WH Message Lines";
                    begin
                        EdiMessage.RESET();
                        CurrPage.SETSELECTIONFILTER(EdiMessage);
                        EdiMessage.MODIFYALL("Error Found", FALSE);
                        EdiMessage.MODIFYALL("Error Description", '');
                    end;
                }
                // >> GX202316

                // >> GX202316 - New Change
                /*
                                action("Skip Inventory Decrease")
                                {
                                    Caption = 'Skip Inventory Decrease';
                                    Ellipsis = true;
                                    Promoted = true;
                                    PromotedIsBig = true;
                                    Image = DecreaseIndent;
                                    trigger OnAction()
                                    var
                                        EdiMessage: Record "GXL WH Message Lines";
                                        DocumentNoCheck: Text;
                                        ConfirmationQst: Label 'Do you want to set skip inventory decrease for the selected line?';
                                    begin
                                        if not Confirm(ConfirmationQst) then
                                            exit;

                                        CurrPage.SETSELECTIONFILTER(EdiMessage);
                                        if EdiMessage.FindSet() then
                                            repeat
                                                DocumentNoCheck := EdiMessage."Document No.";
                                                if (DocumentNoCheck.Contains('_INCREASE')) and (EdiMessage.Processed) then begin
                                                    EdiMessage."Skip Decrease" := true;
                                                    EdiMessage.Modify();
                                                end;
                                            until EdiMessage.Next() = 0;
                                    end;
                                }
                */
                // << GX202316 - New Change                
                action("Linked Entry")
                {
                    Caption = 'Linked Entry';
                    Ellipsis = true;
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = Link;
                    trigger OnAction()
                    var
                        EdiMessage: Record "GXL WH Message Lines";
                        EdiMessage2: Record "GXL WH Message Lines";
                        StockAdjustment: Page "GXL 3PL Stock Adjustment";
                    begin
                        if not EdiMessage2.Get(Rec."Decrease Entry No.") then
                            if EdiMessage2.Get(Rec."Increase Entry No.") then;

                        EdiMessage.SetRange("Document No.", EdiMessage2."Document No.");
                        EdiMessage.SetRange("Line No.", EdiMessage2."Line No.");
                        EdiMessage.SetRange("Import Type", EdiMessage2."Import Type");
                        StockAdjustment.SetTableView(EdiMessage);
                        StockAdjustment.RunModal();
                    end;
                }
                // << GX202316
            }
        }
    }
}

