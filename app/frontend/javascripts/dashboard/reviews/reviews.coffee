Review = require('./review')

module.exports = class Reviews
  constructor: (container) ->
    @container = $(container)
    @reviews = @container.find('[data-review-form]')
    @periodSelector = @container.find("select[data-period-selection]")
    @bindEvents()
    @initialize()

  bindEvents: ->
    @periodSelector.on 'change', @updatePeriod

  updatePeriod: ()=>
    periodSearchString = "period=#{@periodSelector.val()}"
    searchString = window.location.search
    if searchString
      if searchString.match /period=\w+/
        window.location.search = searchString.replace /period=\w+/, periodSearchString
      else
        window.location.search += "&#{periodSearchString}"
    else
      window.location.search = periodSearchString

  initialize: ->
    @reviews.each ->
      new Review(@)
