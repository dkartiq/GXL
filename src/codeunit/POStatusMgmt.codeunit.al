codeunit 50055 "GXL PO Status Mgmt"
{
    TableNo = "Purchase Header";
    trigger OnRun()
    begin
        ChangeOrderStatus(Rec);
    end;

    local procedure ChangeOrderStatus(PurchHdr: Record "Purchase Header")
    var
        CurrentOrderStatus: Enum "GXL PO Status";
        ToOrderStatus: Enum "GXL PO Status";
        SingleInstance: Codeunit "GXL Single Instance";
    begin
        CurrentOrderStatus := GetCurrentOrderStatusInEnum(PurchHdr);
        ToOrderStatus := SingleInstance.GetPOStatus_To();
        StatusChangeValidations(CurrentOrderStatus, ToOrderStatus);
        PurchHdr.Validate("GXL Order Status", GetOrderStatusEnumtoOption(ToOrderStatus));
        PurchHdr.Modify(true);
    end;

    local procedure StatusChangeValidations(FromStatus: Enum "GXL PO Status"; ToStatus: Enum "GXL PO Status")
    var
        User: Record User;
        POStatus: Record "GXL PO Status";
        POStatusChangeMapping: Record "GXL PO Status Change Mapping";
    begin
        POStatus.Get(ToStatus);
        if POStatus."Authorized Users" > '' then begin
            User.FilterGroup(2);
            User.SetFilter("User Name", POStatus."Authorized Users");
            User.FilterGroup(0);
            User.SetRange("User Name", UserId);
            if User.IsEmpty then
                Error('You are not authorized to change the Order Status to .', ToStatus);
        end;

        POStatusChangeMapping.SetRange(From, FromStatus);
        POStatusChangeMapping.SetRange("To", ToStatus);
        if POStatusChangeMapping.IsEmpty then
            Error('Order Status change from %1 to %2 is not allowed.', FromStatus, ToStatus);
    end;

    procedure GetCurrentOrderStatusInEnum(PurchHdr: Record "Purchase Header"): Enum "GXL PO Status"
    begin

        case PurchHdr."GXL Order Status" of
            PurchHdr."GXL Order Status"::New:
                exit(Enum::"GXL PO Status"::New);
            PurchHdr."GXL Order Status"::Created:
                exit(Enum::"GXL PO Status"::Created);
            PurchHdr."GXL Order Status"::Placed:
                exit(Enum::"GXL PO Status"::Placed);
            PurchHdr."GXL Order Status"::Confirmed:
                exit(Enum::"GXL PO Status"::Confirmed);
            PurchHdr."GXL Order Status"::"Booked to Ship":
                exit(Enum::"GXL PO Status"::"Booked to Ship");
            PurchHdr."GXL Order Status"::Shipped:
                exit(Enum::"GXL PO Status"::Shipped);
            PurchHdr."GXL Order Status"::Arrived:
                exit(Enum::"GXL PO Status"::Arrived);
            PurchHdr."GXL Order Status"::Cancelled:
                exit(Enum::"GXL PO Status"::Cancelled);
            PurchHdr."GXL Order Status"::Closed:
                exit(Enum::"GXL PO Status"::Closed);
        end;

    end;

    procedure GetNewStatus(CurrStatus: Enum "GXL PO Status") NewStatus: Enum "GXL PO Status"
    var
        POStatusMapping: Record "GXL PO Status Change Mapping";
    begin
        POStatusMapping.SetRange(From, CurrStatus);
        NewStatus := CurrStatus;
        if POStatusMapping.Count > 0 then
            if Page.RunModal(Page::"GXL PO Status Lookup", POStatusMapping) = Action::LookupOK then
                NewStatus := POStatusMapping."To";
        exit(NewStatus);
    end;

    procedure GetOrderStatusEnumtoOption(EnumStatus: enum "GXL PO Status"): Integer
    begin
        case EnumStatus of
            EnumStatus::New:
                exit(0);
            EnumStatus::Created:
                exit(1);
            EnumStatus::Placed:
                exit(2);
            EnumStatus::Confirmed:
                exit(3);
            EnumStatus::"Booked to Ship":
                exit(4);
            EnumStatus::Shipped:
                exit(5);
            EnumStatus::Arrived:
                exit(6);
            EnumStatus::Cancelled:
                exit(7);
            EnumStatus::Closed:
                exit(8)
        end;
    end;
}