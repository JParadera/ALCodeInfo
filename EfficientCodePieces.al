===================================================
//Código estándar que crea nuevos records en tablas relacionadas a través de un campo común.
//En este caso copiamos la información de un producto cuando creamos otro nuevo con la función estándar "Copiar producto".
Codeunit 790 "Copy Item" 
                              //Tabla a copiar  Rec.FieldNo("Item") Item del que copio   Item al que copio
procedure CopyItemRelatedTable(TableId: Integer; FieldNo: Integer; FromItemNo: Code[20]; ToItemNo: Code[20])
    var
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
    begin
        SourceRecRef.Open(TableId);
        SourceFieldRef := SourceRecRef.Field(FieldNo);
        SourceFieldRef.SetRange(FromItemNo);
        if SourceRecRef.FindSet() then
            repeat
                TargetRecRef := SourceRecRef.Duplicate();
                TargetFieldRef := TargetRecRef.Field(FieldNo);
                TargetFieldRef.Value(ToItemNo);
                TargetRecRef.Insert();
            until SourceRecRef.Next() = 0;
    end;
///////////////////////////////////////////////////

//Ejemplo de llamada a procedure CopyItemRelatedTable:

local procedure CopyItemVendors(FromItemNo: Code[20]; ToItemNo: Code[20])
    var
        ItemVendor: Record "Item Vendor";
    begin
        if not CopyItemBuffer."Item Vendors" then
            exit;

        CopyItemRelatedTable(DATABASE::"Item Vendor", ItemVendor.FieldNo("Item No."), FromItemNo, ToItemNo);
    end;
///////////////////////////////////////////////////
                                        //RecRef con el Rec a enviar  //RecRef.FieldNo  Item del que copio    Item al que copio
procedure CopyItemRelatedTableFromRecRef(var SourceRecRef: RecordRef; FieldNo: Integer; FromItemNo: Code[20]; ToItemNo: Code[20])
    var
        TargetRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
    begin
        SourceFieldRef := SourceRecRef.Field(FieldNo);
        SourceFieldRef.SetRange(FromItemNo);
        if SourceRecRef.FindSet() then
            repeat
                TargetRecRef := SourceRecRef.Duplicate();
                TargetFieldRef := TargetRecRef.Field(FieldNo);
                TargetFieldRef.Value(ToItemNo);
                TargetRecRef.Insert();
            until SourceRecRef.Next() = 0;
    end;
///////////////////////////////////////////////////

//Ejemplo de llamada a procedure CopyItemRelatedTableFromRecRef:

local procedure CopyItemComments(FromItemNo: Code[20]; ToItemNo: Code[20])
    var
        CommentLine: Record "Comment Line";
        RecRef: RecordRef;
    begin
        if not CopyItemBuffer.Comments then
            exit;

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::Item);

        RecRef.GetTable(CommentLine);
        CopyItemRelatedTableFromRecRef(RecRef, CommentLine.FieldNo("No."), FromItemNo, ToItemNo);
    end;
===================================================
