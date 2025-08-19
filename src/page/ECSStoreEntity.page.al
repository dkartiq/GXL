page 50166 "GXL ECS Store Entity"
{
    PageType = API;
    Caption = 'ecsStores', Locked = true;
    APIPublisher = 'gxl';
    APIGroup = 'gxl';
    APIVersion = 'v1.0';
    EntityName = 'ecsStore';
    EntitySetName = 'ecsStores';
    SourceTable = "GXL ECS Store Data";
    SourceTableView = sorting(Entity) where(Entity = filter(Store));
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
                field(storeCode; Rec."Store Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeName; Rec."Store Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeAddress; Rec."Store Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeAddress2; Rec."Store Address 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeCity; Rec."Store City")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storePostCode; Rec."Store Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeCountryRegionCode; Rec."Store Country/Region Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeRegionName; Rec."Store Region Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeOpenDate; Rec."Store Open Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(storeCLosedDate; Rec."Store CLosed Date")
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
        if xRec."Store Code" <> Rec."Store Code" then
            Error('Value of storeCode is immutable.');
    end;

}