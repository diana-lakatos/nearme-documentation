Modal = require('../../components/modal')
require('select2/select2')

module.exports = class ShippingProfiles
  constructor: (form, @profile_add_success = false) ->
    @form = $(form)
    @setupZoneInputs()
    @setupZoneKind()
    @setupShippingMethods()
    @modalSuccessActions()

  modalSuccessActions: =>
    if @profile_add_success
      Modal.close()

      params = { form: 'products' }
      url = location.href
      if !url.match(/\/dashboard\//)
        params['form'] = 'boarding'

      url_for_shipping_categories = '/dashboard/shipping_categories/get_shipping_categories_list'
      if url.match(/instance_admin/)
        url_for_shipping_categories = '/instance_admin/shipping_options/shipping_profiles/get_shipping_categories_list'

      jQuery.ajax
        type: 'get'
        url: url_for_shipping_categories
        data: params
        success: (data) ->
          $('.shipping_method_block.shipping_method_list').empty()
          $('.shipping_method_block.shipping_method_list').append(data)

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
    that = this
    @form.find(".zone_kind_select").each ->
      that.enableZoneSelect($(this))

    that = this
    @form.find(".zone_kind_select").change ->
      that.enableZoneSelect($(this).parent().find(".zone_kind_select"))


  enableZoneSelect: (select) ->
    if $(select).val() == 'state_based'
      $(select).closest(".state_based_select").parent().show()
      $(select).closest(".state_based_select").removeAttr('disabled')
      $(select).closest(".country_based_select").parent().hide()
      $(select).closest(".country_based_select").attr('disabled','disabled')
    else
      $(select).closest(".country_based_select").parent().show()
      $(select).closest(".country_based_select").removeAttr('disabled')
      $(select).closest(".state_based_select").parent().hide()
      $(select).closest(".state_based_select").attr('disabled','disabled')

  setupShippingMethods: ->
    @form.find(".remove_shipping_profile:not(:first)").removeClass('hidden')

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
