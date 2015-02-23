class InstanceAdmin.FormComponentsManager

  constructor: () ->
    $('select[data-form-component-form-type]').change ->
      location.href = '?form_type=' + $(this).val()
