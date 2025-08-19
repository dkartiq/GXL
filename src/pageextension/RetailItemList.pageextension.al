pageextension 50008 "GXL Retail Item List" extends "LSC Retail Item LIst"
{
    layout
    {
        addafter(Description)
        {
            field("GXL Item Category Description"; GXL_strText[1])
            {
                ApplicationArea = All;
                Caption = 'Item Category Description';
                Editable = false;
            }
            field("GXL Retail Product Code Description"; GXL_strText[2])
            {
                ApplicationArea = All;
                Caption = 'Retail Product Group Description';
                Editable = false;
            }
            field("GXL Sub Category3 Description"; GXL_strText[3])
            {
                ApplicationArea = All;
                Caption = 'Sub Category3 Description';
                Editable = false;
            }

            field("GXL Sub Category4 Description"; GXL_strText[4])
            {
                ApplicationArea = All;
                Caption = 'Sub Category4 Description';
                Editable = false;
            }
        }
        addafter("Stockkeeping Unit Exists")
        {
            field("GXL GXLSignage 1"; Rec."GXL Signage 1")
            {
                ApplicationArea = All;
            }
        }
        addafter("Retail Product Code")
        {
            field("GXL Category Code"; Rec."GXL Category Code")
            {
                ApplicationArea = All;
            }
            field("GXL GXLSub Category3 Code"; Rec."GXL Sub Category3 Code")
            {
                ApplicationArea = All;
            }
            field("GXL GXLSub Category4 Code"; Rec."GXL Sub Category4 Code")
            {
                ApplicationArea = All;
            }
        }
        addafter("Replenishment Calculation Type")
        {
            field("GXL Supplier Number"; Rec."GXL Supplier Number")
            {
                ApplicationArea = All;
            }
            field("GXL Distributor Number"; Rec."GXL Distributor Number")
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.GXLGetFamilyStructureDescText(GXL_strText);
    end;

    var
        GXL_strText: array[5] of Text;

}