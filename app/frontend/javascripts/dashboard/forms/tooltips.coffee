DEFAULTS = require '../../shared/tooltips_defaults'

tooltips = (context = 'body') ->
  $(context).find('[data-toggle="tooltip"]').tooltip(DEFAULTS)

module.exports = tooltips
