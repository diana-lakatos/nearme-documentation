$('[rel=tooltip]').tooltip();

$(document).on('init:tooltips.nearme', function(e, containerElement) {
  $(containerElement).find('[data-toggle="tooltip"]').tooltip({ placement: 'right' });
});
