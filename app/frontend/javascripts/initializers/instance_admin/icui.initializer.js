$('.line-item-btn').popover();

var input = $('input[type=hidden].icui');
if (input.length > 0) {
  require.ensure('../../../vendor/icui', function() {
    require('../../../vendor/icui');
    return input.icui();
  });
}
