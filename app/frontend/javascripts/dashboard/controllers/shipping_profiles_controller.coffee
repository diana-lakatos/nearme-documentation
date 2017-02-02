require 'selectize/dist/js/selectize'

module.exports = class ShippingProfilesController
  constructor: (el) ->
    @form = $(el)
    @countriesInput = @form.find('select')
    @worldwideCheckbox = @form.find('[data-worldwide]')
    @bindEvents()
    @initializeSelectize()
    @modalSuccessActions()

  bindEvents: ->
    @form.on 'change', '[data-shippo-for-price]', (e) ->
      if $(e.target).is(':checked')
        $(e.target).closest('.shipping-form').find('[data-price-field]').prop('disabled', true)
      else
        $(e.target).closest('.shipping-form').find('[data-price-field]').prop('disabled', false)

    @form.on 'change', '[data-worldwide]', (e) ->
      if $(e.target).is(':checked')
        $(e.target).closest('.shipping-form').find('select')[0].selectize.disable()
      else
        $(e.target).closest('.shipping-form').find('select')[0].selectize.enable()

    $(document).on 'cocoon:after-insert', (e,insertedItem) =>
      @initializeSelectize(insertedItem)

  initializeSelectize: (container) ->
    $(container).find('select[multiple=multiple]').selectize()

  modalSuccessActions: =>
    return unless @form.data('profile-add-success')

    $(document).trigger('hide:dialog.nearme')

    $.ajax
      type: 'get'
      url: '/dashboard/shipping_profiles/get_shipping_profiles_list'
      data: { form: 'transactables' }
      success: (data) ->
        $('[data-shipping-methods-list]').html(data)
