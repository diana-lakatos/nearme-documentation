const DEFAULTS = require('../../shared/tooltips_defaults');

$('[rel=tooltip]').tooltip(DEFAULTS);

$(document).on('init:tooltips.nearme', function(e, containerElement) {
  $(containerElement).find('[data-toggle="tooltip"]').tooltip(DEFAULTS);
});
