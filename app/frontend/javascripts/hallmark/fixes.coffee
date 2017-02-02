module.exports = class Fixes
  constructor: ->

  @enhancements: ->
    # Add class .last-child to all relevant elements in older browsers
    if !document.addEventListener
      $('*:last-child').addClass('last-child')


  @initialize: ->
    @enhancements()

