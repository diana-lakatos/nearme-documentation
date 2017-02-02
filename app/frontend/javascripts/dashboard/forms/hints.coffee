tooltips = require('./tooltips')

hints = (context = 'body') ->
  $(context).find('.form-group .help-block.hint').each ->
    content = $(this).text()
    content = content.replace(/"/g,'&quot;')
    toggler = $('<button type="button" class="hint-toggler" data-toggle="tooltip" title="' + content + '">Toggle hint</button>')
    context = $(this).closest('.form-group').find('label.control-label')
    context.append(toggler)
    tooltips(context)

module.exports = hints
