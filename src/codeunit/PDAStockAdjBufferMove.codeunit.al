codeunit 50024 "GXL PDA Stock Adj Buffer-Move"
{
    /*
    Change Log:
        PS-2210: Restructured to move function to separate codeunit to handle error such as deadlock
    */

    trigger OnRun()
    begin
        case MoveFromTableId of
            Database::"GXL PDA-Stock Adj. Buffer":
                MovePDAStockAdjBuffer();
            Database::"GXL WH Message Lines":
                MoveWHMessageLine();
        end;

    end;

    var
        FromBuffer: Record "GXL PDA-Stock Adj. Buffer";
        ToBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        WHMessageLines: Record "GXL WH Message Lines";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        LastRMSID: Integer;
        MoveFromTableId: Integer;

    local procedure MovePDAStockAdjBuffer()
    begin
        LastRMSID += 1;
        ToBuffer.Init();
        ToBuffer.TransferFields(FromBuffer);
        ToBuffer."Entry No." := 0;
        ToBuffer.Status := ToBuffer.Status::" ";
        if ToBuffer."Legacy Item No." = '' then
            LegacyItemHelpers.GetLegacyItemNo(ToBuffer."Item No.", ToBuffer."Unit of Measure Code", ToBuffer."Legacy Item No.");
        ToBuffer."RMS ID" := LastRMSID; //<< PS-1386
        ToBuffer.Insert(true);

        FromBuffer.Delete();

    end;

    local procedure MoveWHMessageLine()
    begin
        ToBuffer.Init();
        ToBuffer."Entry No." := 0;
        ToBuffer.Type := ToBuffer.Type::ADJ;
        ToBuffer."Store Code" := WHMessageLines."Location Code";
        ToBuffer."Document No." := WHMessageLines."Document No.";
        //Legacy Item
        //From WH, the item sent is legacy item number
        //ToBuffer."Item No." := WHMessageLines."Item No.";
        ToBuffer."Legacy Item No." := WHMessageLines."Item No.";
        LegacyItemHelpers.GetItemNo(ToBuffer."Legacy Item No.", ToBuffer."Item No.", ToBuffer."Unit of Measure Code");
        ToBuffer."Stock on Hand" := ABS(WHMessageLines."Qty. To Receive");
        ToBuffer."Reason Code" := WHMessageLines."Reason Code";
        ToBuffer."Created Date Time" := CreateDateTime(WHMessageLines."Date Imported", WHMessageLines."Time Imported");
        ToBuffer.Status := ToBuffer.Status::" ";
        if WHMessageLines.Description <> '' then begin
            ToBuffer."Claim-to Document Type" := ToBuffer."Claim-to Document Type"::PO;
            ToBuffer."Claim-to Order No." := WHMessageLines.Description;
        end;
        ToBuffer.Insert(true);

        WHMessageLines.Processed := true;
        WHMessageLines.Modify();

    end;

    procedure SetPDAStockAdjBuffer(var NewPDAStockAdjBuffer: Record "GXL PDA-Stock Adj. Buffer")
    begin
        FromBuffer := NewPDAStockAdjBuffer;
    end;

    procedure SetWHMessageLine(var NewWHMessageLine: Record "GXL WH Message Lines")
    begin
        WHMessageLines := NewWHMessageLine;
    end;

    procedure SetLastRMSID(NewRMSID: Integer)
    begin
        LastRMSID := NewRMSID;
    end;

    procedure GetLastRMSID(var NewRMSID: Integer)
    begin
        NewRMSID := LastRMSID;
    end;

    procedure SetMoveFromTable(NewTableId: Integer)
    begin
        MoveFromTableId := NewTableId;
    end;
}