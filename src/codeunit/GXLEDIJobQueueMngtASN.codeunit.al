//<Summary>
//ASN process includes sub-processes 
//to be executed in sequence of ASN Header's status: Imported > Validated > Processed > Scanned > Received
//  
//  Import ASN
//      - Import ASN Header/Lines for EDI Orders
//      - Import/Process PDA-PL Receive Buffer to update purchase order qty. to receive
//  Validate ASN
//  Process ASN
//  Scann ASN Log Info
//      - For P2P Contingency orders: 
//          PDA-PL Receive Buffer are created from MIM
//          Create ASN Header/Lines from the above PDA-PL Receive Buffer, status is set to Scanned
//      - For EDI orders that locations are 3PL EDI: 
//          Import ASN scan log from xml port 50069 
//      - For other EDI from non 3PL-EDI locations
//          ASN scanned log are created from MIM
//      - Process the ASN scanned log to update the purchase order qty. to receive 
//  Receive ASN: post/receive the purchase order
//
//for claimable received qty, additional processess to be executed:
//  Create return order 
//  Apply return order to the original receipt
//  Post the return shipment
//</Summary>
codeunit 50391 "GXL GXLEDI Job Queue Mngt ASN"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ValidateExportASN();
        ImportAdvanceShippingNotice();
        ValidateAdvanceShippingNotice();
        ProcessAdvanceShippingNotice();
        CopyScannedAdvanceShippingNotice();
        ReceiveAdvanceShippingNotice();
        CreateReturnOrder();
        ApplyReturnOrder();
        PostReturnShipment();
    end;

    local procedure ImportAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 1);
        EDIProcessMgt.RUN();
    end;

    local procedure ValidateAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 2);
        EDIProcessMgt.RUN();
    end;

    local procedure ProcessAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 3);
        EDIProcessMgt.RUN();
    end;


    local procedure CopyScannedAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        //ProcessWhat : Validate and Export,Import,Validate,Process,Scan,Receive,Create Return Order,Apply Return Order,Post Return Shipment,Post Return Credit
        EDIProcessMgt.SetOptions(3, 4);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure ReceiveAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 5);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure CreateReturnOrder()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 6);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure ApplyReturnOrder()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 7);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure PostReturnShipment()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 8);
        EDIProcessMgt.RUN();
    end;


    local procedure ValidateExportASN()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 0);
        EDIProcessMgt.RUN();
    end;
}

