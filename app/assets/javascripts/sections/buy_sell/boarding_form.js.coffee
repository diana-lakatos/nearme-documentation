class @BoardingForm
  constructor: (@form) ->
    @setupZoneInputs()
    @setupZoneKind()
    @setupShippingMethods()
    @obsrvePhotoAdd()

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
      @form.find(".state_based_select").show().removeAttr('disabled');
      @form.find(".country_based_select").hide().attr('disabled','disabled');
    else
      @form.find(".country_based_select").show().removeAttr('disabled');
      @form.find(".state_based_select").hide().attr('disabled','disabled');

  obsrvePhotoAdd: ->
    @form.find(".item_image").change ->
      $(this).parent().css("background-color", "#DEFCE8")
      $(this).parent().css("border-color", "#809900")
      fullPath = $(this).val()
      if fullPath
        startIndex = ((if fullPath.indexOf("\\") >= 0 then fullPath.lastIndexOf("\\") else fullPath.lastIndexOf("/")))
        filename = fullPath.substring(startIndex)
        filename = filename.substring(1)  if filename.indexOf("\\") is 0 or filename.indexOf("/") is 0
        $(this).parent().find(".photo-select").text(filename)

  setupShippingMethods: ->
    for shipping_hidden in @form.find(".shipping_hidden")
      if $(shipping_hidden).prop("checked")
        $(shipping_hidden).parents(".shipping_method_block").hide()

    @form.find(".shipping_hidden").change ->
      console.log(shipping_hidden)
      if $(this).prop("checked")
        console.log('checked')
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










