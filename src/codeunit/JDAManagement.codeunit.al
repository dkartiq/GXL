codeunit 50052 "GXL JDA Management"
{
    procedure GetPOType(PurchaseHeader: Record "Purchase Header") POTypeText: Text
    var
        L_Vendor: Record Vendor;
    begin

        POTypeText := '';
        IF NOT L_Vendor.GET(PurchaseHeader."Buy-from Vendor No.") THEN
            EXIT;
        CASE PurchaseHeader."GXL Source of Supply" OF
            PurchaseHeader."GXL Source of Supply"::WH:
                BEGIN
                    IF L_Vendor."GXL Import Flag" = FALSE THEN
                        POTypeText := 'Warehouse Local'
                    ELSE
                        POTypeText := 'Warehouse Import'
                END;
            PurchaseHeader."GXL Source of Supply"::SD:
                POTypeText := 'Store Direct';

            PurchaseHeader."GXL Source of Supply"::XD:
                POTypeText := 'Cross Dock';
            PurchaseHeader."GXL Source of Supply"::FT:
                POTypeText := 'Flow Through';
        END;
    end;
}