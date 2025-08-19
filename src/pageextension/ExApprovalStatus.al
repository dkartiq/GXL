pageextension 50355 "Ex Approval Status" extends "Ex Approval Status"
{

    actions
    {
        addafter("Force Update of Purchase Document")
        {
            action(Delete)
            {
                Promoted = true;
                PromotedCategory = Process;
                Image = Delete;
                trigger OnAction()
                var
                    ExDoc: Record "Ex Document";
                begin
                    if (Rec.GetFilter("Document No.") > '') and (Rec.GetFilter(Status) > '') then begin
                        CurrPage.SetSelectionFilter(ExDoc);
                        ExDoc.DeleteAll(true);
                    end else
                        Error('Apply filter on the Document no and Status field');
                end;
            }
        }
    }
}