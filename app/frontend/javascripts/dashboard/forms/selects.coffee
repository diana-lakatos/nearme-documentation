require 'selectize/dist/js/selectize'

selects = (context = 'body')->
  $(context).find('.form-group select').each ->
    options =
      onInitialize: ->
        s = @;
        @revertSettings.$children.each ()->
          $.extend(s.options[@value], $(@).data())

    if $(this).attr('multiple')
      options.plugins = ['remove_button']

    options.allowEmptyOption = !!$(this).data('allow-empty-option')

    $(document).trigger('plugin:loaded.selectize');

    $(this).selectize(options)

module.exports = selects
