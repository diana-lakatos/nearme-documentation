class @InstanceAdmin.SearchServiceTypesController extends @InstanceAdmin.SearchTransactableTypeController

  transactable_type_class_name: =>
    return '.service_type'

  data_selector_name: =>
    return 'data-service-type-custom-attributes'

  transactable_data: (checkbox) =>
    return { transactable_type: {searchable: checkbox.prop('checked')}}