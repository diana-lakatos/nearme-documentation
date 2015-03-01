class @BoardingForm
  constructor: (@form) ->
    @setupZoneInputs()
    @setupZoneKind()
    @setupShippingMethods()
    @setupDocumentRequirements()
    @setupImages()

  setupZoneInputs: =>
    for input in @form.find(".select2")
      $(input).select2
        multiple: true
        initSelection: (element, callback) ->
          url = '/dashboard/api/' + $(input).attr('data-api') + "?ids="+ element.val()
          $.getJSON url, null, (data) ->
            callback data
        ajax:
          url: '/dashboard/api/' + $(input).attr('data-api')
          datatype: "json"
          data: (term, page) ->
            per_page: 50
            page: page
            q:
              name_cont: term

          results: (data, page) ->
            more = page < data.pages
            results: data
            more: more

        formatResult: (country) ->
          country.name

        formatSelection: (country) ->
          country.name

  setupZoneKind: =>
    @enableZoneSelect(@form.find(".zone_kind_select"))
    that = this
    @form.find(".zone_kind_select").change ->
      that.enableZoneSelect($(this).parent().find(".zone_kind_select"))


  enableZoneSelect: (select) ->
    if $(select).val() == 'state_based'
      @form.find(".state_based_select").parent().show()
      @form.find(".state_based_select").removeAttr('disabled');
      @form.find(".country_based_select").parent().hide()
      @form.find(".country_based_select").attr('disabled','disabled');
    else
      @form.find(".country_based_select").parent().show()
      @form.find(".country_based_select").removeAttr('disabled');
      @form.find(".state_based_select").parent().hide()
      @form.find(".state_based_select").attr('disabled','disabled');

  processImage: (event, container) ->
    $(container).find('label').hide()
    $(container).append("<img src='" + event.fpfile.url + "'>")
    $(container).append('<label class="delete_image">Delete</label>')
    @setupImages()

  setupImages: ->
    @form.find(".delete_image").click ->
      $(this).parent().hide()

  setupShippingMethods: ->
    nestedForm = new SetupNestedForm(@form)
    nestedForm.setup(".remove_shipping_profile:not(:first)", 
                ".shipping_hidden", ".remove_shipping", 
                ".shipping_method_block", 
                ".add_shipping_profile")

  setupDocumentRequirements: ->
    nestedForm = new SetupNestedForm(@form)
    nestedForm.setup(".remove-document-requirement:not(:first)", 
                ".document-hidden", ".remove-document", 
                ".document-requirement", 
                ".document-requirements .add-new", true)
