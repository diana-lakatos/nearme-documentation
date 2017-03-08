module.exports = class SubscriptionPricing
  constructor: ->
    @initialize()

  initialize: ->
    @unit_selects = $('[data-subscription-unit]')

    $('.nested-fields-set').on 'cocoon:after-insert', (e, insertedItem) =>
      insertedSelect = $(insertedItem).find('[data-subscription-unit]')
      insertedSelect.on 'change', (event) =>
        @toggleProRata($(event.target))
      @toggleProRata(insertedSelect)

    @unit_selects.on 'change', (event) =>
      @toggleProRata($(event.target))

    @unit_selects.each (index, el) =>
      @toggleProRata($(el))

  toggleProRata: (select)  ->
    proRata = select.parents('.row').find('[data-pro-rated]')
    if select.val() == 'subscription_month'
      proRata.parents('.control-group').show()
    else
      proRata.parents('.control-group').hide()
