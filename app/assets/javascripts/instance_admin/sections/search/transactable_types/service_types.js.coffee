class @InstanceAdmin.SearchServiceTypesController extends @InstanceAdmin.SearchTransactableTypeController

  transactable_type_class_name: =>
    return '.service_type'

  data_selector_name: =>
    return 'data-service-type-custom-attributes'

  transactable_data: (checkbox) =>
    data = { transactable_type: {}}
    data.transactable_type[checkbox.prop('name')] = checkbox.prop('checked')
    data