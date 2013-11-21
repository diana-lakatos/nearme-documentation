class Bookings.ReservationRequestFormController

  constructor: (@container) ->
    @container.find('#reservation_request_card_number').payment('formatCardNumber')
    @container.find('#reservation_request_card_expires').payment('formatCardExpiry')
    @container.find('#reservation_request_card_code').payment('formatCardCVC')
