//CR029: Average Cost trapping
xmlport 50001 "GXL AvgCostChangeLog-Export"
{
    Caption = 'Average Cost Change Log - Export';
    Direction = Export;
    Format = VariableText;
    FormatEvaluate = Legacy;

    schema
    {
        textelement(root)
        {
            tableelement(AvgCostChangeLog; "GXL Average Cost Change Log")
            {
                fieldelement(EntryNo; AvgCostChangeLog."Entry No.")
                { }
                fieldelement(ItemNo; AvgCostChangeLog."Item No.")
                { }
                fieldelement(UnitCostBefore; AvgCostChangeLog."Unit Cost Before Run")
                { }
                fieldelement(UnitCostAfter; AvgCostChangeLog."Unit Cost After Run")
                { }
                fieldelement(AvgCostBefore; AvgCostChangeLog."Average Cost Before Run")
                { }
                fieldelement(AvgCostAfter; AvgCostChangeLog."Average Cost After Run")
                { }
                fieldelement(ValueEntryNoBefore; AvgCostChangeLog."Last Value Entry Before Run")
                { }
                fieldelement(ValueEntryNoAfter; AvgCostChangeLog."Last Value Entry After Run")
                { }
                fieldelement(DateRun; AvgCostChangeLog."Run Date")
                { }
                fieldelement(TimeRun; AvgCostChangeLog."Run Time")
                { }
            }
        }
    }


    var

}