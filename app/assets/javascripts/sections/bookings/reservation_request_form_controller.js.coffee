class Bookings.ReservationRequestFormController

  constructor: (@container) ->
    @container.find('#card_number').payment('formatCardNumber')
    @container.find('#card_expires').payment('formatCardExpiry')
    @container.find('#card_code').payment('formatCardCVC')
