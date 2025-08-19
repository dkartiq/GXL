page 50171 "GXL ECS Promotion Entity"
{
    PageType = API;
    Caption = 'ecsPromotions', Locked = true;
    APIPublisher = 'gxl';
    APIGroup = 'gxl';
    APIVersion = 'v1.0';
    EntityName = 'ecsPromotion';
    EntitySetName = 'ecsPromotions';
    SourceTable = "GXL ECS Promotion Data";
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
                field(ecsEventID; Rec."ECS Event ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(eventCode; Rec."Event Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(promotionType; Rec."Promotion Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(locationHierarchyType; Rec."Location Hierarchy Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(locationHierarchyCode; Rec."Location Hierarchy Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ecsClusterUID; Rec."ECS Cluster UID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(itemNumber; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(unitOfMeasureCode; Rec."Unit Of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(defaultSize; Rec."Default Size")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(discountValue1; Rec."Discount Value 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(discountValue2; Rec."Discount Value 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(discountQuantity; Rec."Discount Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(dealText1; Rec."Deal Text 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(dealText2; Rec."Deal Text 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(dealText3; Rec."Deal Text 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(startDate; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(endDate; Rec."End Date")
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