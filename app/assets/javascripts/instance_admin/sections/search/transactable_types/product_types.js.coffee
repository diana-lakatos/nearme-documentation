class @InstanceAdmin.SearchProductTypesController extends @InstanceAdmin.SearchTransactableTypeController

  transactable_type_class_name: =>
    '.product_type'
  data_selector_name: =>
    return 'data-product-type-custom-attributes'

  transactable_data: (checkbox) =>
    return { product_type: {searchable: checkbox.prop('checked')}}