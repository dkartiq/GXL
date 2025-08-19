codeunit 50257 "GXL PDA-Staging PL CaptionMgt"
{
    SingleInstance = true;

    trigger OnRun()
    begin

    end;

    var
        GlobalPDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        GlobalField: Record Field;


    procedure GetPDAStgingPurchaseLineCaptionClass(var PDAStagingPL: Record "GXL PDA-Staging Purch. Line"; FieldNumber: Integer): Text
    begin
        if (GlobalPDAStagingPH."No." <> PDAStagingPL."Document No.") then
            if not GlobalPDAStagingPH.Get(PDAStagingPL."Document No.") then
                Clear(GlobalPDAStagingPH);

        case FieldNumber of
            PDAStagingPL.FieldNo("No."):
                exit(StrSubstNo('3,%1', GetFieldCaption(Database::"GXL PDA-Staging Purch. Line", FieldNumber)));
            else begin
                if GlobalPDAStagingPH."Prices Including VAT" then
                    exit('2,1,' + GetFieldCaption(Database::"GXL PDA-Staging Purch. Line", FieldNumber));
                exit('2,0,' + GetFieldCaption(Database::"GXL PDA-Staging Purch. Line", FieldNumber));
            end;
        end;
    end;

    local procedure GetFieldCaption(TableNumber: Integer; FieldNumber: Integer): Text
    begin
        if (GlobalField.TableNo <> TableNumber) or (GlobalField."No." <> FieldNumber) then
            GlobalField.Get(TableNumber, FieldNumber);
        exit(GlobalField."Field Caption");
    end;
}