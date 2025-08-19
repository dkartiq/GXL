page 50378 "GXL Incoterms"
{
    Caption = 'Incoterms';
    PageType = List;
    SourceTable = "GXL Incoterms";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                }
                field(Description; Rec.Description)
                {
                }
                //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
                /*
                field("No. of Vendors"; "No. of Vendors")
                {
                }
                */
            }
        }
        area(factboxes)
        {
            systempart(Control1101214005; Notes)
            {
            }
            systempart(Control1101214006; Links)
            {
            }
        }
    }

    actions
    {
        area(navigation)
        {
            // TODO International/Domestic PO - Not needed for now
            // action(Vendors)
            // {
            //     Caption = 'Vendors';
            //     Image = List;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     RunObject = Page "Vendor List";
            //     RunPageLink = "GXL Incoterms Code" = FIELD(Code);
            // }
        }
    }
}

