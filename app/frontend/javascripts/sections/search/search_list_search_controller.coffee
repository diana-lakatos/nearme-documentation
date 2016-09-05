SearchSearchController = require('./search_controller')

module.exports = class SearchListSearchController extends SearchSearchController
  constructor: (form, @container) ->
    super(form, @container)
    @initializePriceSlider()

  reinitializePriceSlider: =>
    $('#price-slider').remove()
    $('.price-slider-container').append('<div id="price-slider"></div>')
    super

