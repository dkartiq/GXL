table 50036 "API Message Log"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "API Type"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "API Payload"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Status; enum "API Message Status")
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Processing Start"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Processing End"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Error Text"; Text[2048])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "API Source"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Lock Retry"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure GetRelatedXMLPortID() XMLPortID: Integer
    begin
        XMLPortID := 0;
        case lowercase("API Type") of
            'stockadjustment':
                case "API Source" of
                    'WMS':
                        XMLPortID := 50272;
                    'Linfox':
                        XMLPortID := 50094;
                    'Chill':
                        XMLPortID := 50094;
                    else
                        XMLPortID := 50094;
                end;
            'stockonhand':
                case "API Source" of
                    'WMS':
                        XMLPortID := 50273;
                    'Linfox':
                        XMLPortID := 50097;
                    'Chill':
                        XMLPortID := 50097;
                    else
                        XMLPortID := 50097;
                end;
            'poreceiptquantity':
                case "API Source" of
                    'WMS':
                        XMLPortID := 50270;
                    'Linfox':
                        XMLPortID := 50270;
                    'Chill':
                        XMLPortID := 50270;
                    else
                        XMLPortID := 50270;
                end;
            'transfershipmentquantity':
                case "API Source" of
                    'WMS':
                        XMLPortID := 50271;
                    'Linfox':
                        XMLPortID := 50271;
                    'Chill':
                        XMLPortID := 50271;
                    else
                        XMLPortID := 50271;
                end;
            'ediasnreceipt':
                XMLPortID := 50069;
            'salesorder':
                XMLPortID := Xmlport::"GXL WH Sales Order";
        end;
    end;

    procedure GetProcessTypeByAPIType() ProcessType: Integer;
    begin
        ProcessType := 0;

        case lowercase("API Type") of
            'stockadjustment':
                ProcessType := 1;
            'stockonhand':
                ProcessType := 1;
            'poreceiptquantity':
                ProcessType := 1;
            'transfershipmentquantity':
                ProcessType := 1;
            'ediasnreceipt':
                ProcessType := 2;
            'salesorder': //WMSVD-002
                ProcessType := 1;
        end;
    end;

    procedure IsAPITypeEnabledForLocation(inLocationCode: Code[20]; inAPIType: Text) IsEnabled: Boolean
    var
        APIEnablePerLocation: Record "API Enable Per Location";
    begin
        IsEnabled := false;

        APIEnablePerLocation.SetRange("Location Code", inLocationCode);
        APIEnablePerLocation.SetRange("API Type", APIEnablePerLocation."API Type"::all);

        if APIEnablePerLocation.IsEmpty then begin
            APIEnablePerLocation.SetRange("API Type");

            case lowercase(inAPIType) of
                'stockadjustment':
                    APIEnablePerLocation.SetRange("API Type", APIEnablePerLocation."API Type"::stockadjustment);
                'stockonhand':
                    APIEnablePerLocation.SetRange("API Type", APIEnablePerLocation."API Type"::stockonhand);
                'poreceiptquantity':
                    APIEnablePerLocation.SetRange("API Type", APIEnablePerLocation."API Type"::poreceiptquantity);
                'transfershipmentquantity':
                    APIEnablePerLocation.SetRange("API Type", APIEnablePerLocation."API Type"::transfershipmentquantity);
                'ediasnreceipt':
                    APIEnablePerLocation.SetRange("API Type", APIEnablePerLocation."API Type"::ediasnreceipt);
                'salesorder':
                    APIEnablePerLocation.SetRange("API Type", APIEnablePerLocation."API Type"::salesorder);
            end;
        end;

        IsEnabled := not APIEnablePerLocation.IsEmpty;
    end;

    procedure PayloadToTextAsDecoded() outString: Text;
    var
        StreamIn: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        Base64Text: Text;
    begin
        outString := '';

        CALCFIELDS("API Payload");

        if not "API Payload".HasValue() then
            exit;

        "API Payload".CreateInStream(StreamIn);

        StreamIn.ReadText(Base64Text);

        outString := Base64Convert.FromBase64(Base64Text);
    end;

    procedure PayloadToTextAsBase64() outString: Text;
    var
        StreamIn: InStream;
        Base64Text: Text;
    begin
        outString := '';

        CALCFIELDS("API Payload");

        if not "API Payload".HasValue() then
            exit;

        "API Payload".CreateInStream(StreamIn);

        StreamIn.ReadText(Base64Text);

        outString := Base64Text;
    end;
}