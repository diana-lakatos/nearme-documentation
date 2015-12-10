require 'selectize/dist/js/selectize'

module.exports = class ShippingProfilesController
  constructor: (el) ->
    @form = $(el)
    @zoneWrappers = @form.find('[data-ships-to]')
    @zoneKindSelects = @form.find("[data-zone-kind-select]")
    @addRuleButton = @form.find("[data-add-rule]")
    @hiddenInputs = @form.find('.shipping-hidden')
    @removedInputs = @form.find('.shipping-removed')
    @bindEvents()
    @initialize()

  bindEvents: ->
    @zoneKindSelects.on 'change', (e) =>
      @enableZoneSelect($(e.target).closest('.shipping-method'), $(e.target).val())

    @hiddenInputs.on 'change', ->
      $(this).parents(".shipping-method").toggle !$(this).is(':checked')

    @removedInputs.on 'change', ->
      $(this).parents(".shipping-method").hide() if $(this).is(":checked")

    @addRuleButton.on 'click', =>
      @hiddenInputs.filter(':checked').eq(0).prop('checked', false).trigger("change")
      @addRuleButton.hide() if @hiddenInputs.filter(':checked').length == 0

  initialize: ->
    @zoneKindSelects.each (index, item)=>
      @enableZoneSelect($(item).closest('.shipping-method'), $(item).val())

    @setupZoneInputs()
    @setupShippingMethods()

    @modalSuccessActions()

  modalSuccessActions: =>
    return unless @form.data('profile-add-success')

    $('html').trigger('hide.dialog')

    $.ajax
      type: 'get'
      url: '/dashboard/shipping_categories/get_shipping_categories_list'
      data: { form: 'products' }
      success: (data) ->
        $('[data-shipping-methods-list]').html(data)


  setupZoneInputs: =>

    @zoneWrappers.each (index, item)=>
      wrapper = $(item)
      input = $(item).find('[data-api]')

      input.selectize
        create: false,
        valueField: 'id',
        labelField: 'name',
        searchField: 'name',
        options: input.data('items'),
        load: (query, callback)->
          return callback() unless query.length

          $.ajax
            url: '/dashboard/api/' + input.data('api'),
            type: 'GET',
            dataType: 'json',
            data:
              q:
                name_cont: query
            error: ->
              callback()

            success: (res)->
              callback(res)

  enableZoneSelect: (parent, method) ->
    @toggleZoneSelect parent.find('[data-ships-to="countries"]'), (method == 'country')
    @toggleZoneSelect parent.find('[data-ships-to="states"]'), (method == 'state_based')

  toggleZoneSelect: (wrapper, state)->
    wrapper.toggle(state)
    input = wrapper.find('input')
    selectize = input.get(0).selectize

    if state
      input.removeAttr('disabled')
      if selectize
        selectize.enable()
    else
      input.attr('disabled', 'disabled')
      if selectize
        selectize.disable()


  setupShippingMethods: ->
    @form.find(".remove_shipping_profile:not(:first)").removeClass('hidden');

    @hiddenInputs.filter(':checked').closest(".shipping-method").hide()
    @removedInputs.filter(':checked').closest(".shipping-method").hide()
