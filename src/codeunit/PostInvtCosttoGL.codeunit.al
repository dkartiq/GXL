/// <summary>
/// ERP-270 - CR104 - Performance improvement post cost to G/L
/// Codeunit to call Post inventory cost to G/L for range of selected records only
/// </summary>
codeunit 50036 "GXL Post InvtCost to G/L"
{
    TableNo = "Post Value Entry to G/L";

    trigger OnRun()
    var
        PostValueEntryToGL: Record "Post Value Entry to G/L";
        GXLPostInventoryCostToGL: Report "GXL Post Inventory Cost to G/L";
    begin
        PostValueEntryToGL.Copy(Rec);

        Clear(GXLPostInventoryCostToGL);
        GXLPostInventoryCostToGL.InitializeRequest(PostMethod, DocNo, true);
        GXLPostInventoryCostToGL.SetTableView(PostValueEntryToGL);
        GXLPostInventoryCostToGL.UseRequestPage(false);
        GXLPostInventoryCostToGL.RunModal();
    end;

    var
        PostMethod: Option "per Posting Group","per Entry";
        DocNo: Code[20];


    procedure SetProperties(NewPostMethod: Option "per Posting Group","per Entry"; NewDocNo: Code[20])
    begin
        PostMethod := NewPostMethod;
        DocNo := NewDocNo;
    end;


}