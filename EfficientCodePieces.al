//Las líneas con =================================================== separan funcionalidades completamente.
//Las líneas con /////////////////////////////////////////////////// sólo separan trozos de la misma funcionalidad para adjuntar ejemplos o comentarios.

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

//Código estándar por el que se calcula el precio de un producto en base a su lista de materiales.
//Lo que interesa de esta función es la forma de calcular el precio para la línea de venta. El estándar va a comprobar lo necesario y selecciona el precio adecuado para la fecha / cliente.

table 904 "Assemble-to-Order Link"

procedure RollUpPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")

  var
      PriceCalculationMgt: codeunit "Price Calculation Mgt.";
      LineWithPrice: Interface "Line With Price";
      PriceCalculation: Interface "Price Calculation";
      PriceType: Enum "Price Type";
  begin
      SalesLine.GetLineWithPrice(LineWithPrice);
      LineWithPrice.SetLine(PriceType::Sale, SalesHeader, SalesLine);
      PriceCalculationMgt.GetHandler(LineWithPrice, PriceCalculation);
      SalesLine.ApplyPrice(SalesLine.FieldNo("No."), PriceCalculation);
  end;
///////////////////////////////////////////////////

//Comentarios sobre procedure RollUpPrice:
// - El estándar la usa para crear líneas de venta ficticias por cada producto en la lista de materiales, calcular sus precios para multiplicarlo por cantidades y al final sumar el resultado de cada una para tener
// el precio final del producto padre.
// - Esta parte del código inserta el precio de venta directamente en el campo "Unit Price" del Record sobre el que ejecutamos la función ApplyPrice en este caso "Sales Line".
// - La función dentro de la interface LineWithPrice.SetLine es abierta, sólo pide variables Variant para Header y Line, no tiene porque ser las de venta o las de pedido.

===================================================

//Código más simple para poder sacar nuevas agrupaciones de actions en las páginas (nivel Promoted) y que las acciones se vean dentro del grupo nuevo o en el que se ha especificado.
//Ejemplo inventado propio en una PageExt de la página 22 "Customer List" (usando snippet tactions):

actions
    {
        addlast(Processing)
            {
                action("Create Cust. Category")
                  {
                      Image = CreateFrom;
                      ApplicationArea = All;
                      Caption = 'Crear categoría cliente';

                      trigger OnAction();
                      var
                        cuCreateCustCat: Codeunit "GEN Create Customer Category";

                      begin
                          cuCreateCustCat.CreateCategory();
                      end;
                  }   
            }
        addlast(Promoted)
            {
              group(GENCustomerCategory)
                {
                  Caption = 'Categoría cliente';
                  actionref(CreateCustCategory; "Create Cust. Category")
                    {
                    }
                }
            }
    }

///////////////////////////////////////////////////

//Comentarios sobre agrupaciones de páginas:
// - La parte del addlast(Promoted) y el group(GENCustomerCategory) crea un grupo al final de la barra de acciones con todas las actionref que queramos incluir, no tienen por que ser acciones creadas por nosotros,
// pueden ser acciones estándar que ya existen en la página.

===================================================

//Código para crear vistas en páginas en páginas desde el código por defecto para que aparezcan disponibles para los usuarios sin configuración.
//Ejemplo propio de nuevo en una PageExt de la página 22 "Customer List" (usando snippet tview):

views
  {
      view(ActiveCustomers)
        {
            Caption = 'Clientes activos';
            Filters = where(Blocked = const(false));
            OrderBy = ascending("No.");
        }

      view(BlockedCustomers)
        {
            Caption = 'Clientes bloqueados':
            Filters = where(Blocked = const(true));
            SharedLayout = false;
            layout
              {
                movefirst(Control1; "Blocked")
              }
        }
  }
///////////////////////////////////////////////////

//Comentarios sobre las vistas en páginas:
// - Cuando se omite la función SharedLayout el valor por defecto es true y mantiene la estructura de la página en la vista creada. Sin embargo, cuando lo marcamos falso pordemos aplicar cambios en la vista
// con respecto a la página incial (en este caso mover el campo "Blocked" al comienzo de la lista").
// - Los filtros admiten const, filter y field y se pueden agrupar varios filtos separados por ",".

===================================================





