page 50173 "GXL ECS Stock Range Entity"
{
    PageType = API;
    Caption = 'ecsStockRange', Locked = true;
    APIPublisher = 'gxl';
    APIGroup = 'gxl';
    APIVersion = 'v1.0';
    EntityName = 'ecsStockRange';
    EntitySetName = 'ecsStockRange';
    SourceTable = "GXL ECS Stock Range Data";
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
                field(locationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(itemNumber; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(unitOfMeasureCode; Rec.UOM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(stockonHand; Rec."Stock on Hand")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ranged; Rec.Ranged)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(rangeStartDate; Rec."Range Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(rangeEndDate; Rec."Range End Date")
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
    end;

}