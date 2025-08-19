codeunit 50054 "GXL Perform Manual Reopen"
{
    TableNo = "Transfer Header";
    trigger OnRun()
    var
        ReleaseTransfer: Codeunit "Release Transfer Document";
    begin
        ReleaseTransfer.Reopen(Rec);
    end;

}