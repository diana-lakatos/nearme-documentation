module.exports = class SetupNestedForm
  constructor: (@form) ->

  setup: (removeLink, hiddenField, removeField, wrapper, newLink, setupUploadObligation = false) ->
    @form.find(removeLink).removeClass('hidden')

    for hiddenElement in @form.find(hiddenField)
      if $(hiddenElement).prop("checked")
        $(hiddenElement).parents(wrapper).hide()

    @form.find(hiddenField).change ->
      if $(this).prop("checked")
        $(this).parents(wrapper).hide('slow')
      else
        $(this).parents(wrapper).show('slow')

    for removeElement in @form.find(removeField)
      if $(removeElement).prop("checked")
        $(removeElement).parents(wrapper).hide()

    @form.find(removeField).change ->
      if ($(this).prop("checked"))
        $(this).parents(wrapper).hide("slow")

    @form.find(newLink).click =>
      @form.find(hiddenField + ":checked").eq(0).prop('checked', false).trigger("change")
      if @form.find(hiddenField + ":checked").length == 0
        @form.find(newLink).hide()

    if setupUploadObligation
      @form.find('.document-requirements input[type="radio"]').change (e) =>
        if $(e.currentTarget).val() is 'Not Required'
          for hiddenElement in @form.find(hiddenField)
            if $(hiddenElement).parents(wrapper).is(':visible')
              $(hiddenElement).data('hide', true)
              $(hiddenElement).prop("checked", true)
          @form.find('.document-requirements .document-requirements-fields').hide('slow')
        else
          for hiddenElement in @form.find(hiddenField)
            if $(hiddenElement).data('hide')
              $(hiddenElement).prop("checked", false)
              $(hiddenElement).removeData('hide')
          @form.find('.document-requirements .document-requirements-fields').removeClass('hidden')
          @form.find('.document-requirements .document-requirements-fields').show('slow')


