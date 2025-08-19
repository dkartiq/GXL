page 50088 "GXL Harmony Integrator"
{
    PageType = API;
    Editable = true;
    DelayedInsert = true;
    Caption = 'HarmonyIntegrator', Locked = true;
    APIPublisher = 'WMS';
    APIGroup = 'WMS';
    APIVersion = 'v1.0';
    EntityName = 'HarmonyIntegrator';
    EntitySetName = 'HarmonyIntegrator';
    ModifyAllowed = false;
    DeleteAllowed = false;

    SourceTable = "Api Message Log";

    layout
    {
        area(content)
        {
            field(APIType; Rec."API Type")
            {
            }
            field(APIPayload; Rec."API Payload")
            {
            }
            field(APISource; Rec."API Source")
            {
                Caption = 'API Source';
            }
            field(LocationCode; Rec."Location Code")
            {
                Caption = 'Location Code';
            }
            field(Status;Rec.Status)
            {
                Editable = false;
            }
            field(ErrorText;Rec."Error Text")
            {
                Editable = false;
            }
        }
    }
}