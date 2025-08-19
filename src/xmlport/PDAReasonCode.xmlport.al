// 11.08.2025 HP2-Sprint2 Changed the Xmlport number form 50253 to 50090.
// >> HP2-sprint2
// xmlport 50090 "GXL PDA-Reason Code"
xmlport 50090 "GXL PDA-Reason Code"
// << HP2-sprint2
{
    Caption = 'PDA-Reason Code';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/ReasonCode';
    Encoding = UTF16;

    schema
    {
        textelement(Root)
        {
            MinOccurs = Once;
            MaxOccurs = Once;
            tableelement(ReasonCodes; "Reason Code")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(ReasonCode; ReasonCodes.Code)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Description; ReasonCodes.Description)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(AuditReason; ReasonCodes."GXL Audit Reason Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(StkAdj; ReasonCodes."GXL Stock Adj.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(POVar; ReasonCodes."GXL PO. Variance")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Claimable; ReasonCodes."GXL Claimable")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ShortSupply; ReasonCodes."GXL PDA Short Supply")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(OverSupply; ReasonCodes."GXL PDA Over Supply")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var

    procedure SetXMLFilterMR(UllageFilter: Text; StockAdjOnly: Boolean)
    begin
        ReasonCodes.SetFilter("GXL Ullaged", UllageFilter);
        if StockAdjOnly then
            ReasonCodes.SetRange("GXL Stock Adj.", true);
    end;

    // >> LCB-120
    procedure SetXMLFilterMRILC(SourceOfSupplyP: Enum "GXL Source of Supply")
    begin
        case SourceOfSupplyP of
            SourceOfSupplyP::SD:
                ReasonCodes.SetFilter("GXL Source of Supply", '%1|%2', ReasonCodes."GXL Source of Supply"::SD, ReasonCodes."GXL Source of Supply"::"Both SD and WH");
            SourceOfSupplyP::WH:
                ReasonCodes.SetFilter("GXL Source of Supply", '%1|%2', ReasonCodes."GXL Source of Supply"::WH, ReasonCodes."GXL Source of Supply"::"Both SD and WH");
            else
                ReasonCodes.SetFilter("GXL Source of Supply", '<>%1', ReasonCodes."GXL Source of Supply"::" ");
        end;
    end;
    // << LCB-120
}