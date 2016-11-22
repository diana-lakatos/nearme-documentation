tooltips = (context = 'body')->
  $(context).find('[data-toggle="tooltip"]').tooltip({
    placement: 'auto right'
  })

module.exports = tooltips
