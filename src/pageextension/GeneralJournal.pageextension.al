pageextension 50043 "GXL General Journal" extends "General Journal"
{
    actions
    {
        addlast(Processing)
        {
            //CR103 - G/L Import +
            action("GXL GLImportPetbarn")
            {
                ApplicationArea = All;
                Caption = 'Import General Journal - Petbarn';
                Image = Import;
                trigger OnAction()
                begin
                    Xmlport.Run(xmlport::"GXL Gen. Jnl. Import - Petbarn", false, true);
                    CurrPage.Update();
                end;
            }
            action("GXL GLImportVet")
            {
                ApplicationArea = All;
                Caption = 'Import General Journal - Vet';
                Image = Import;
                trigger OnAction()
                begin
                    Xmlport.Run(xmlport::"GXL Gen. Jnl. Import - Vet", false, true);
                    CurrPage.Update();
                end;
            }
            //CR103 - G/L Import -
        }
    }
}
