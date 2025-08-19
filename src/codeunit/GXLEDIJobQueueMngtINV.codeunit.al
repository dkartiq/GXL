//<Summary>
//Invoice process includes sub-processes
//to be executed in sequence of INV PO Header's status: Imported > Validated > Processed
//
//  Import Invoice
//      - For EDI orders (VAN)
//          Import to PO INV Header/Line
//      - For P2P or P2P Contingency orders
//          Xml port 50356 to import into EDI-Purchase Messages
//          From the imported EDI-Purchase Messages, create PO INV Header/Line      
//  Validate Invoice
//  Process Invoice: post (invoice) the purchase order
//
//For claimable purchase qty
//  Post return order
//</Summary>
codeunit 50392 "GXL GXLEDI Job Queue Mngt INV"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ImportInvoice();
        ValidateInvoice();
        ProcessInvoice();
        PostReturnCredit();
    end;

    local procedure ImportInvoice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(4, 1);
        EDIProcessMgt.RUN();
    end;

    local procedure ValidateInvoice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(4, 2);
        EDIProcessMgt.RUN();
    end;

    local procedure ProcessInvoice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(4, 3);
        EDIProcessMgt.RUN();
    end;

    procedure PostReturnCredit()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(4, 9);
        EDIProcessMgt.RUN();
    end;
}

