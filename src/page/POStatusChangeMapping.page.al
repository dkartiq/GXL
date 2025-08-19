page 10016882 "GXL PO Status Change Mapping"
{
    PageType = List;
    SourceTable = "GXL PO Status Change Mapping";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(From; Rec.From) { ApplicationArea = All; }
                field("To"; Rec."To") { ApplicationArea = all; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Add)
            {
                Image = Add;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    FromStatus: Enum "GXL PO Status";
                    FromStatusFilter: Text;
                begin
                    FromStatusFilter := Rec.GetFilter(From);
                    if FromStatusFilter = '' then
                        exit;

                    Evaluate(FromStatus, FromStatusFilter);
                    Rec.AddRecords(FromStatus);
                end;
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec.From = Rec."To" then
            Error('The "From" and "To" statuses cannot be the same.');
        exit(true);
    end;
}