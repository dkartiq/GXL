page 50170 "GXL ECS Item Content Entity"
{
    PageType = API;
    Caption = 'ecsItemContent', Locked = true;
    APIPublisher = 'gxl';
    APIGroup = 'gxl';
    APIVersion = 'v1.0';
    EntityName = 'ecsItemContent';
    EntitySetName = 'ecsItemContent';
    SourceTable = "GXL ECS Item Data";
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
                field(itemNumber; Rec."Unique ID 1 ECS Field Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(unitOfMeasureCode; Rec."Unique ID 2 ECS Field Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ecsFieldName; Rec."ECS Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(fieldValue; Rec."Field Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(printTicket; Rec."Print Ticket")
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