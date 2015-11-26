class @DNM.Listings.BookingType

  constructor: (el)->
    @container = $(el)
    @input = $('input[data-booking-type]')
    @tabs = @container.find('[data-toggle="tab"]')
    @defineDay = $('.define-a-day')
    @bindEvents()
    @initTabs()

  bindEvents: =>
    @tabs.on 'show.bs.tab', (e) =>
      @changeBookingType(e.target)

    @input.on 'change', (e) =>
      if @defineDay.length > 0
        if @input.val() == 'subscription'
          @defineDay.addClass('form-section-disabled')
          @defineDay.find('input').prop('disabled', true)
        else if @input.val() == 'regular'
          @defineDay.removeClass('form-section-disabled')
          @defineDay.find('input').prop('disabled', false)

  changeBookingType: (el)->
    @input.val $(el).data('booking-type')
    if $(el).data('booking-type') == 'regular'
      $('.price-options input[type=checkbox]').trigger('change')

  initTabs: ->
    if @input.val() != 'schedule'
      @tabs.filter("[data-booking-type='regular']").tab('show')
    else
      @tabs.filter("[data-booking-type='#{@input.val()}']").tab('show')

$('[data-booking-type-list]').each ->
  new DNM.Listings.BookingType(@)
