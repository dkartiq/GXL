enum 50256 "GXL Non-EDI Process Step"
{
    Extensible = false;

    value(0; "Validate and Export")
    { }
    value(1; Import)
    { }
    value(2; Validate)
    { }
    value(3; Process)
    { }
    value(4; Scan)
    { }
    value(5; Receive)
    { }
    value(6; "Create Return Order")
    { }
    value(7; "Apply Return Order")
    { }
    value(8; "Post Return Shipment")
    { }
    value(9; "Post Return Credit")
    { }
    value(10; "Complete without Posting Return Credit")
    { }
    value(11; "Clear Buffer")
    { }
    value(12; "Move To Processing Buffer")
    { }
    value(13; "Clear PDA Receiving Buffer Errors")
    { }

}