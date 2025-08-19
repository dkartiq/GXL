// >> Upgrade
// Unable to extend the table SMTP Account and hence a new table has been created table 50400 "SMTP Account Extension"
// tableextension 50014 "GXL SMTP Mail Setup" extends "SMTP Mail Setup"
// {
//     fields
//     {
//         field(50350; "GXL Maximum Message Size in MB"; Integer)
//         {
//             Caption = 'Maximum Message Size in MB';
//             DataClassification = CustomerContent;
//             InitValue = 0;
//             MinValue = 0;
//         }
//     }

// }
// << Upgrade