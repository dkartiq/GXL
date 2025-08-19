xmlport 50047 "GXL ASN-Inbound Purchase Order"
{
    Direction = Both;
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = true;

    schema
    {
        textelement(Root)
        {
            tableelement("PDA-Purchase Lines"; "GXL PDA-Purchase Lines")
            {
                MinOccurs = Once;
                XmlName = 'PurchaseLines';
                //PS-2428+
                /*
                AutoSave = true;
                //AutoReplace = true;
                AutoUpdate = true;
                */
                UseTemporary = true;
                //PS-2428-
                fieldelement(PONumber; "PDA-Purchase Lines"."Document No.")
                {
                }
                textelement(LineNo)
                {
                }
                textelement(ILC)
                {

                    trigger OnAfterAssignVariable()
                    var
                        PurchaseLine: Record "Purchase Line";
                    begin
                        PurchaseLine.Reset();
                        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                        PurchaseLine.SetFilter("Document No.", "PDA-Purchase Lines"."Document No.");
                        //PurchaseLine.SetFilter("No.", ILC);
                        PurchaseLine.SetRange("GXL Legacy Item No.", ILC);
                        if PurchaseLine.FindFirst() then begin
                            "PDA-Purchase Lines"."Line No." := PurchaseLine."Line No.";
                            "PDA-Purchase Lines"."Item No." := PurchaseLine."No.";
                            "PDA-Purchase Lines"."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                        end else begin
                            //PurchaseLine.SetRange("No.");
                            PurchaseLine.SetRange("GXL Legacy Item No.");
                            PurchaseLine.SetFilter("GXL Vendor Reorder No.", ILC); // GXL Vendor Reorder No. is still the legacy Item No
                            if PurchaseLine.FindFirst() then begin
                                "PDA-Purchase Lines"."Line No." := PurchaseLine."Line No.";
                                "PDA-Purchase Lines"."Item No." := PurchaseLine."No.";
                                "PDA-Purchase Lines"."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                            end else
                                Error(ILC + ' is not on Purchase Order ' + "PDA-Purchase Lines"."Document No.");
                        end;
                        DocNo := "PDA-Purchase Lines"."Document No.";
                    end;
                }
                fieldelement(ReceiveQty; "PDA-Purchase Lines".QtyOrdered)
                {
                }
                fieldelement(QtyVar; "PDA-Purchase Lines".QtyToReceive)
                {
                }
            }
        }
    }

    trigger OnPostXmlPort()
    begin
        //PS-2428+
        //if DocNo <> '' then
        //    WHDataMgt.ReceiveASNLines(DocNo);
        ReceiveASNLines();
        //PS-2428-
    end;

    var
        WHDataMgt: Codeunit "GXL WH Data Management";
        DocNo: Code[20];

    [Scope('OnPrem')]
    procedure SetXmlFilter(PONumber: Code[20])
    begin
        //"Purchase Line".SETRANGE("Purchase Line"."Document No.",PONumber);
    end;

    //PS-2428+
    local procedure ReceiveASNLines()
    var
        TempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary;
    begin
        if DocNo <> '' then begin
            Clear(WHDataMgt);
            TempPDAPurchaseLines.Reset();
            TempPDAPurchaseLines.DeleteAll();
            if "PDA-Purchase Lines".FindSet() then
                repeat
                    TempPDAPurchaseLines := "PDA-Purchase Lines";
                    TempPDAPurchaseLines.Insert();
                until "PDA-Purchase Lines".Next() = 0;

            WHDataMgt.ReceiveASNLines(DocNo, TempPDAPurchaseLines);
        end;
    end;
    //PS-2428-

}

