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
