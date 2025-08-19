page 50383 "GXL 3PL Packing Slip"
{
    Caption = '3PL Packing Slip';
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GXL WH Message Lines";
    SourceTableView = SORTING("Document No.", "Line No.", "Import Type") WHERE("Import Type" = FILTER("Purchase Order" | "Transfer Order" | "Sales Order"));
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
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
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
                field("Qty. Variance"; Rec."Qty. Variance")
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
                // >> LCB-297
                field("Time Imported"; Rec."Time Imported")
                {
                    ApplicationArea = All;
                }
                // << LCB-297
                //WMSVD-002->>----------------------------------
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                }
                field("Created Document No."; Rec."Created Document No.")
                {
                    ApplicationArea = All;
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                }
                //<<-WMSVD-002---------------------------
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
                    Image = ResetStatus;
                    Ellipsis = true;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        EdiMessage: Record "GXL WH Message Lines";
                        EdiMessage2: Record "GXL WH Message Lines";
                    begin
                        EdiMessage.RESET();
                        CurrPage.SETSELECTIONFILTER(EdiMessage);

                        IF EdiMessage.FINDSET(TRUE, TRUE) THEN
                            REPEAT
                                EdiMessage2 := EdiMessage;
                                EdiMessage2."Error Found" := FALSE;
                                EdiMessage2."Error Description" := '';
                                EdiMessage2.MODIFY();
                            UNTIL EdiMessage.NEXT() = 0;
                    end;
                }
            }
        }
    }
}

