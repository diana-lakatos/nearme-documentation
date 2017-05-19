var DEFAULTS, tooltips;

DEFAULTS = require('../../shared/tooltips_defaults');

tooltips = function(context) {
  if (context == null) {
    context = 'body';
  }
  return $(context).find('[data-toggle="tooltip"]').tooltip(DEFAULTS);
};

module.exports = tooltips;
