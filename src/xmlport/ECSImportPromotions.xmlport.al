xmlport 50150 "GXL ECS Import Promotions"
{
    Caption = 'ECS Import Promotions';
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = false;

    schema
    {
        textelement(PromoRoot)
        {
            tableelement(Promos; "GXL ECS Promotion Line")
            {
                MinOccurs = Once;
                MaxOccurs = Unbounded;

                textelement(EventCode)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                textelement(EventName)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                textelement(PromotionType)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                textelement(LocationHierarchyType)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                textelement(LocationHierarchyCode)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                textelement(StartDate)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                textelement(EndDate)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(ItemNo; Promos."Item No.")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(UOM; Promos."Unit Of Measure Code")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DiscountValue1; Promos."Discount Value 1")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DiscountValue2; Promos."Discount Value 2")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DiscountQuantity; Promos."Discount Quantity")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DealText1; Promos."Deal Text 1")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DealText2; Promos."Deal Text 2")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DealText3; Promos."Deal Text 3")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DefaultSize; Promos."Default Size")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }

                trigger OnBeforeInsertRecord()
                var
                    LHTypeInt: Integer;
                begin

                    LineCounter += 1;

                    if LocationHierarchyType in ['All', 'State', 'Region', 'Cluster', 'Location'] then begin
                        case LocationHierarchyType of
                            'All':
                                LHTypeInt := 1;
                            'State':
                                LHTypeInt := 2;
                            'Region':
                                LHTypeInt := 3;
                            'Cluster':
                                LHTypeInt := 4;
                            'Location':
                                LHTypeInt := 5;
                        end;
                    end else
                        Error(InvalidLocHierarchyTypeErr, LocationHierarchyType, LineCounter);

                    if not PromoHeader.Get(EventCode, PromotionType, LHTypeInt, LocationHierarchyCode) then begin
                        PromoHeader.Init();
                        PromoHeader."Event Code" := EventCode;
                        PromoHeader."Event Name" := EventName;
                        PromoHeader."Promotion Type" := PromotionType;
                        PromoHeader."Location Hierarchy Type" := LHTypeInt;
                        PromoHeader."Location Hierarchy Code" := LocationHierarchyCode;
                        PromoHeader."ECS Event ID" := 0;
                        Evaluate(PromoHeader."Start Date", StartDate);
                        Evaluate(PromoHeader."End Date", EndDate);
                        PromoHeader.Insert(true);
                    END;

                    Promos."Entry No." := 0;
                    Promos."ECS Event ID" := PromoHeader."ECS Event ID";
                    Promos."Created Date Time" := CurrentDateTime();
                end;
            }
        }
    }

    var
        PromoHeader: Record "GXL ECS Promotion Header";
        LineCounter: Integer;
        InvalidLocHierarchyTypeErr: Label 'Invalid Location Hierarchy Type %1 on Line No. %2';
}