hints = (context = 'body')->
  $(context).find('.form-group .help-block.hint').each ()->
    content = $(this).html()
    toggler = $('<button type="button" class="hint-toggler" data-toggle="tooltip" data-placement="right" title="' + content + '">Toggle hint</button>')
    $(this).closest('.form-group').find('label.control-label').append(toggler)

module.exports = hints
