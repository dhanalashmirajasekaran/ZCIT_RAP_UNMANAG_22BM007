@AccessControl.authorizationCheck: #NOT_REQUIRED 
@EndUserText.label: 'Sales Order Item Consumption View' 
@Search.searchable: true 
@Metadata.ignorePropagatedAnnotations: true 
@Metadata.allowExtensions: true 

define view entity ZCIT_SALE_O_C 
  as projection on ZCIT_SALE_O 
{ 
  key SalesDocument, 
  key SalesItemnumber, 
      @Search.defaultSearchElement: true 
      Material, 
      Plant, 
      @Semantics.quantity.unitOfMeasure: 'Quantityunits' 
      Quantity, 
      Quantityunits, 
      LocalCreatedBy, 
      LocalCreatedAt, 
      LocalLastChangedBy, 
      LocalLastChangedAt, 
       
      /* Associations */ 
      _salesHeader : redirected to parent ZCIT_SALE_C 
}
