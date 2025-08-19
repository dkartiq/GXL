table 50386 "GXL EDI Email Setup"
{
    Caption = 'EDI Email Setup';
    DrillDownPageID = "GXL EDI Email Setup";
    LookupPageID = "GXL EDI Email Setup";

    fields
    {
        field(1; "Area of Emailing"; Option)
        {
            Caption = 'Area of Emailing';
            Description = 'pv00.03,MCS1.76';
            OptionCaption = 'PO Exp,GTIN Valid,POR Imp,POR Valid,POR Proc,ASN Imp,ASN Valid,ASN Proc,ASN Scan Valid,ASN Scan Proc,ASN Receive,ASN Rec Discr,ASN Ret Ord Creation,ASN Ret Ord Appl,ASN Ret Ship Post,INV Imp,INV Valid,INV ProcINV Cr Post,INV Credit Notif,P2P POR Imp,P2P POR Valid,P2P POR Proc,P2P ASN Imp,P2P INV Imp,P2P INV Valid,P2P INV Proc,P2P INV Cr Post,P2P INV Cr Notif,PO Scan Proc,PO Rec,PO Rec Discr,PO Ret Ord Creation,PO Ret Appl,PO Ret Ship Post,PO INV Post,PO Cr Creation,PO Cr Appl,PO Cr Post,PO Cr Post Notifi,PO Cr Creation Notif,Stk Adj Valid,StkAdj Creation,Stk Adj App,Stk Adj Post,Manual Inv,ASN Exp,3PL Imp,EDI PDA Rec B. Cl,NEDI PDA Rec B. Cl,P2P PDA Rec B. CL,AdvImp,AdvValid,AdvProc,AckImp,AckValid,AckProc';
            OptionMembers = "PO Exp","GTIN Valid","POR Imp","POR Valid","POR Proc","ASN Imp","ASN Valid","ASN Proc","ASN Scan Valid","ASN Scan Proc","ASN Receive","ASN Rec Discr","ASN Ret Ord Creation","ASN Ret Ord Appl","ASN Ret Ship Post","INV Imp","INV Valid","INV ProcINV Cr Post","INV Credit Notif","P2P POR Imp","P2P POR Valid","P2P POR Proc","P2P ASN Imp","P2P INV Imp","P2P INV Valid","P2P INV Proc","P2P INV Cr Post","P2P INV Cr Notif","PO Scan Proc","PO Rec","PO Rec Discr","PO Ret Ord Creation","PO Ret Appl","PO Ret Ship Post","PO INV Post","PO Cr Creation","PO Cr Appl","PO Cr Post","PO Cr Post Notifi","PO Cr Creation Notif","Stk Adj Valid","StkAdj Creation","Stk Adj App","Stk Adj Post","Manual Inv","ASN Exp","3PL Imp","EDI PDA Rec B. Cl","NEDI PDA Rec B. Cl","P2P PDA Rec B. CL",AdvImp,AdvValid,AdvProc,AckImp,AckValid,AckProc;
        }
        field(2; "Email To"; Text[250])
        {
            Caption = 'Email To';

            trigger OnValidate()
            var
                EmailFunctions: Codeunit "GXL Email Functions";
            begin
                EmailFunctions.CheckValidEmailAddresses("Email To");
            end;
        }
        field(3; "Email CC"; Text[250])
        {
            Caption = 'Email CC';

            trigger OnValidate()
            var
                EmailFunctions: Codeunit "GXL Email Functions";
            begin
                EmailFunctions.CheckValidEmailAddresses("Email CC");
            end;
        }
        field(4; "Email Supplier"; Boolean)
        {
            Caption = 'Email Supplier/Sender';
            Description = 'MCS1.76';
        }
        field(5; Subject; Text[250])
        {
            Caption = 'Subject';
        }
        field(6; Body; Text[250])
        {
            Caption = 'Body';
        }
    }

    keys
    {
        key(Key1; "Area of Emailing")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

