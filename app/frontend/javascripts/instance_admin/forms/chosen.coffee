require 'chosen-js/chosen.jquery.js'

module.exports = class ChosenInitializer
  constructor: (context) ->
    @initialize(context)

  initialize: (context = 'body') ->
    $(context).find('select.chosen').chosen()
    $(context).find('select.select').chosen({width: '100%'})
