page 50169 "GXL ECS Prod Hierarchy Entity"
{
    PageType = API;
    Caption = 'ecsProductHierarchy', Locked = true;
    APIPublisher = 'gxl';
    APIGroup = 'gxl';
    APIVersion = 'v1.0';
    EntityName = 'ecsProductHierarchy';
    EntitySetName = 'ecsProductHierarchy';
    SourceTable = "GXL ECS Prod. Hierarchy Data";
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
                field(messageType; Rec."Message Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(hierarchyParentType; Rec."Hierarchy Parent Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(hierarchyParentValueCode; Rec."Hierarchy Parent Value Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(hierarchyChildType; Rec."Hierarchy Child Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(hierarchyChildValueCode; Rec."Hierarchy Child Value Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(hierarchyChildDescription; Rec."Hierarchy Child Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(itemNumber; Rec."Item No.")
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