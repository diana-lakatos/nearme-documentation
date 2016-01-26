require 'selectize/dist/js/selectize'

selects = (context = 'body')->
  $(context).find('.form-group select').selectize
    plugins: ['remove_button']
    onInitialize: ->
      s = @;
      @revertSettings.$children.each ()->
        $.extend(s.options[@value], $(@).data())

module.exports = selects
