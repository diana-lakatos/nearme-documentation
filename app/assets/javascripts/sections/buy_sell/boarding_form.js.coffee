class @BoardingForm
  constructor: (@form) ->
    @setupZoneInputs()
    @setupZoneKind()
    @setupShippingMethods()
    @setupImages()

  setupZoneInputs: =>
    for input in @form.find(".select2")
      $(input).select2
        multiple: true
        initSelection: (element, callback) ->
          url = '/manage/buy_sell/api/' + $(input).attr('data-api') + "?ids="+ element.val()
          $.getJSON url, null, (data) ->
            callback data
        ajax:
          url: '/manage/buy_sell/api/' + $(input).attr('data-api')
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
    @form.find(".remove_shipping_profile:not(:first)").removeClass('hidden');

    for shipping_hidden in @form.find(".shipping_hidden")
      if $(shipping_hidden).prop("checked")
        $(shipping_hidden).parents(".shipping_method_block").hide()

    @form.find(".shipping_hidden").change ->
      if $(this).prop("checked")
        $(this).parents(".shipping_method_block").hide('slow')
      else
        $(this).parents(".shipping_method_block").show('slow')

    for shipping_remove in @form.find(".remove_shipping")
      if $(shipping_remove).prop("checked")
        $(shipping_remove).parents(".shipping_method_block").hide()

    @form.find(".remove_shipping").change ->
      if ($(this).prop("checked"))
        $(this).parents(".shipping_method_block").hide("slow")

    @form.find(".add_shipping_profile").click =>
      @form.find(".shipping_hidden:checked").eq(0).prop('checked', false).trigger("change")
      if @form.find(".shipping_hidden:checked").length == 0
        @form.find(".add_shipping_profile").hide()
