module.exports = class FlashMessage
  constructor: (el) ->
    @message = $(el)
    @initStructure()
    @addEventListeners()

  initStructure: ->
    closeLabel = @message.data('close-label')
    btn = $("<button type='button' class='close'><span class='intelicon-close-solid'></span> #{closeLabel}</button>")
    @message.find('.contain').append(btn)

  addEventListeners: ->
    @message.on 'click', '.close', =>
      @message.slideUp()
