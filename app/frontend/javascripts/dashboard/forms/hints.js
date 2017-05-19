var hints, tooltips;

tooltips = require('./tooltips');

hints = function(context) {
  if (context == null) {
    context = 'body';
  }
  return $(context).find('.form-group .help-block.hint').each(function() {
    var content, toggler;
    content = $(this).text();
    content = content.replace(/"/g, '&quot;');
    toggler = $(
      '<button type="button" class="hint-toggler" data-toggle="tooltip" title="' + content +
        '">Toggle hint</button>'
    );
    context = $(this).closest('.form-group').find('label.control-label');
    context.append(toggler);
    return tooltips(context);
  });
};

module.exports = hints;
