pageextension 50045 "GXL General Ledger Entries" extends "General Ledger Entries"
{
    layout
    {
        //ERP-156 - Add fields to G/L Entries page +
        modify("Global Dimension 1 Code")
        {
            Visible = Dim1Visible;
        }
        modify("Global Dimension 2 Code")
        {
            Visible = Dim2Visible;
        }
        addafter("Global Dimension 2 Code")
        {
            field("GXL Shortcut Dimension 3 Code"; ShortcutDimCode[3])
            {
                ApplicationArea = Dimensions;
                Caption = 'Shortcut Dimension 3 Code';
                CaptionClass = '1,2,3';
                Editable = false;
                ToolTip = 'Specifies the code for Shortcut Dimension 3, which is one of dimension codes that you set up in the General Ledger Setup window.';
                Visible = Dim3Visible;
            }
            field("GXL Shortcut Dimension 4 Code"; ShortcutDimCode[4])
            {
                ApplicationArea = Dimensions;
                Caption = 'Shortcut Dimension 4 Code';
                CaptionClass = '1,2,4';
                Editable = false;
                ToolTip = 'Specifies the code for Shortcut Dimension 4, which is one of dimension codes that you set up in the General Ledger Setup window.';
                Visible = Dim4Visible;
            }
            field("GXL Shortcut Dimension 5 Code"; ShortcutDimCode[5])
            {
                ApplicationArea = Dimensions;
                Caption = 'Shortcut Dimension 5 Code';
                CaptionClass = '1,2,5';
                Editable = false;
                ToolTip = 'Specifies the code for Shortcut Dimension 5, which is one of dimension codes that you set up in the General Ledger Setup window.';
                Visible = Dim5Visible;
            }
            field("GXL Shortcut Dimension 6 Code"; ShortcutDimCode[6])
            {
                ApplicationArea = Dimensions;
                Caption = 'Shortcut Dimension 6 Code';
                CaptionClass = '1,2,6';
                Editable = false;
                ToolTip = 'Specifies the code for Shortcut Dimension 6, which is one of dimension codes that you set up in the General Ledger Setup window.';
                Visible = Dim6Visible;
            }
            field("GXL Shortcut Dimension 7 Code"; ShortcutDimCode[7])
            {
                ApplicationArea = Dimensions;
                Caption = 'Shortcut Dimension 7 Code';
                CaptionClass = '1,2,7';
                Editable = false;
                ToolTip = 'Specifies the code for Shortcut Dimension 7, which is one of dimension codes that you set up in the General Ledger Setup window.';
                Visible = Dim7Visible;
            }
            field("GXL Shortcut Dimension 8 Code"; ShortcutDimCode[8])
            {
                ApplicationArea = Dimensions;
                Caption = 'Shortcut Dimension 8 Code';
                CaptionClass = '1,2,8';
                Editable = false;
                ToolTip = 'Specifies the code for Shortcut Dimension 8, which is one of dimension codes that you set up in the General Ledger Setup window.';
                Visible = Dim8Visible;
            }

        }
        addlast(Control1)
        {
            field("GXL Document Date"; Rec."Document Date")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("GXL Business Unit Code"; Rec."Business Unit Code")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("GXL Source No."; Rec."Source No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        //ERP-156 - Add fields to G/L Entries page -
    }

    trigger OnAfterGetRecord()
    begin
        DimensionManagement.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
    end;

    trigger OnOpenPage()
    begin
        GXL_SetDimVisibility();
    end;

    var
        DimensionManagement: Codeunit DimensionManagement;
        ShortcutDimCode: array[10] of Code[20];
        Dim1Visible: Boolean;
        Dim2Visible: Boolean;
        Dim3Visible: Boolean;
        Dim4Visible: Boolean;
        Dim5Visible: Boolean;
        Dim6Visible: Boolean;
        Dim7Visible: Boolean;
        Dim8Visible: Boolean;

    local procedure GXL_SetDimVisibility()
    begin
        DimensionManagement.UseShortcutDims(Dim1Visible, Dim2Visible, Dim3Visible, Dim4Visible, Dim5Visible, Dim6Visible, Dim7Visible, Dim8Visible);
    end;

}