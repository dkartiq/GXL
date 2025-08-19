page 50172 "GXL ECS Sales Price Entity"
{
    PageType = API;
    Caption = 'ecsSalesPrices', Locked = true;
    APIPublisher = 'gxl';
    APIGroup = 'gxl';
    APIVersion = 'v1.0';
    EntityName = 'ecsSalesPrice';
    EntitySetName = 'ecsSalesPrices';
    SourceTable = "GXL ECS Sales Price Data";
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
                field(description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(activeRRP; Rec."Active RRP")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(priceStartDate; Rec."Price Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(priceEndDate; Rec."Price End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(offerType; Rec."Offer Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(priceType; Rec."Price Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ticketQuantity; Rec."Ticket Quantity")
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