codeunit 50056 "GXL Single Instance"
{
    SingleInstance = true;
    procedure SetPOStatus_To(POStatusL: Enum "GXL PO Status")
    begin
        POStatusG := POStatusL;
    end;

    procedure GetPOStatus_To(): Enum "GXL PO Status"
    begin
        exit(POStatusG);
    end;

    var
        POStatusG: Enum "GXL PO Status";
}