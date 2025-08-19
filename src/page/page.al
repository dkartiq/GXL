page 50452 "Json API Test Page"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Name; NameSource)
                {
                    ApplicationArea = All;
                    // MultiLine = true;
                }
                field(Name1; NameSource2)
                {
                    ApplicationArea = All;
                    // MultiLine = true;
                }
                field(Name2; NameSource3)
                {
                    ApplicationArea = All;
                    // MultiLine = true;
                }
                field(Name3; NameSource4)
                {
                    ApplicationArea = All;
                    // MultiLine = true;
                }
                field(Name4; NameSource5)
                {
                    ApplicationArea = All;
                    // MultiLine = true;
                }
                field(Name5; NameSource6)
                {
                    ApplicationArea = All;
                    // MultiLine = true;
                }
                field(Name6; NameSource7)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field(Name7; NameSource8)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    APITest: Codeunit "GXL API Integration Handler";
                begin
                    APITest.Upsert(NameSource, NameSource2, NameSource3, NameSource4, NameSource5, NameSource6, NameSource7);
                end;
            }
            action(ActionName2)
            {
                ApplicationArea = All;
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    APITest: Codeunit "GXL API Integration Handler";
                begin
                    APITest.ProcessAPIRecords();
                end;
            }
            action(ActionName3)
            {
                ApplicationArea = All;
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    APITest: Codeunit "GXL API Integration Handler";
                begin
                    APITest.getRecordValue(NameSource, NameSource2, NameSource3, NameSource4, NameSource5, NameSource6, NameSource8);
                end;
            }
        }
    }

    var
        NameSource8, NameSource, NameSource2, NameSource3, NameSource4, NameSource5, NameSource6, NameSource7 : Text;

}