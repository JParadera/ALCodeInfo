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
                      Caption = 'Crear categoría cliente";

                      trigger OnAction();
                      var
                        cuCreateCustCat: Codeunit "GEN Create Customer Category;

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





