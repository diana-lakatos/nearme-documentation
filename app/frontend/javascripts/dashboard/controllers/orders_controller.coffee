module.exports = class OrdersController

  constructor: (@container) ->
    @detailsLinks = @container.find("[data-order-details]")
    @bindEvents()

  bindEvents: =>
    @detailsLinks.click (e) ->
      e.preventDefault()
      detailsContainer = $(e.target).parents(".order-row").next()
      if detailsContainer.hasClass('hidden')
        detailsContainer.hide().removeClass('hidden').show('slow')
        inputText = $(e.target).text()
        if $(e.target).text() == "Details"
          $(e.target).text('Hide')
      else
        detailsContainer.hide 'slow', ->
          $(this).addClass('hidden')
        if $(e.target).text() == "Hide"
          $(e.target).text('Details')

