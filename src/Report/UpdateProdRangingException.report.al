report 50008 "GXL UpdateProdRangingException"
{
    Caption = 'Update Product Ranging Exceptions';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("GXL Ranging Exceptions"; "GXL Ranging Exceptions")
        {
            RequestFilterFields = "Item No.", "Store Code", "Last Modified Date";

            trigger OnPreDataItem()
            begin
                Clear(ProdRangingMgt);
                ProdRangingMgt.UpdateRangingException("GXL Ranging Exceptions");
                CurrReport.Break();
            end;
        }
    }


    var
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
}