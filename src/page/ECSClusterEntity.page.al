page 50167 "GXL ECS Cluster Entity"
{
    PageType = API;
    Caption = 'ecsClusters', Locked = true;
    APIPublisher = 'gxl';
    APIGroup = 'gxl';
    APIVersion = 'v1.0';
    EntityName = 'ecsCluster';
    EntitySetName = 'ecsClusters';
    SourceTable = "GXL ECS Store Data";
    SourceTableView = sorting(Entity) where(Entity = filter(Cluster));
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    ODataKeyFields = Id;
    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.id)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("action"; Rec.Action)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeGroupCode; Rec."Store Group Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(middlewareUpdateStatus; Rec."Middleware Update Status")
                {
                    ApplicationArea = All;
                }
                field(middlewareUpdateTimestamp; Rec."Middleware Update Timestamp")
                {
                    ApplicationArea = All;
                }
                field(middlewareError; Rec."Middleware Error")
                {
                    ApplicationArea = All;
                }
                field(middlewareErrorMessage; Rec."Middleware Error Message")
                {
                    ApplicationArea = All;
                }
                field(entryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(createdDateTime; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date-Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Id <> Rec.Id then
            Error('Value of id is immutable.');
        if xRec."Last Modified Date-Time" <> Rec."Last Modified Date-Time" then
            Error('Value of lastModifiedDateTime is immutable.');
        if xRec."Entry No." <> Rec."Entry No." then
            Error('Value of entryNo is immutable.');
        if xRec."Store Group Code" <> Rec."Store Group Code" then
            Error('Value of storeGroupCode is immutable.');
    end;

}