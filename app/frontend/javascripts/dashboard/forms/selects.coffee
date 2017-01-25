require 'selectize/dist/js/selectize'

selects = (context = 'body')->
  $(context).find('.form-group select:not(.customSelect)').each ->
    select = this
    options =
      onInitialize: ->
        s = @;
        @revertSettings.$children.each ()->
          $.extend(s.options[@value], $(@).data())
      onChange: ->
        event = new Event('change', {
          'view': window,
          'bubbles': true,
          'cancelable': true
        });
        cancelled = !select.dispatchEvent(event);

    if $(this).attr('multiple')
      options.plugins = ['remove_button']

    options.allowEmptyOption = !!$(this).data('allow-empty-option')

    $(document).trigger('plugin:loaded.selectize');

    $(this).selectize(options)

module.exports = selects
