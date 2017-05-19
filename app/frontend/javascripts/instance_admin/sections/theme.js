var InstanceAdminThemeController;

require('bootstrap-colorpicker/dist/js/bootstrap-colorpicker');

InstanceAdminThemeController = function() {
  function InstanceAdminThemeController(form) {
    this.form = form;
    this.resetLinks = this.form.find('a[data-reset]');
    this.bindEvents();
    $('.color-picker-text-field')
      .colorpicker({ 'format': 'hex' })
      .on('changeColor.colorpicker', function(event) {
        $(event.target)
          .parent()
          .find('.color-picker-color')
          .css('background-color', event.color.toHex());
      });
    $('.color-picker-color').click(function() {
      return $(this).parent().find('.color-picker-text-field').colorpicker('show');
    });
  }

  InstanceAdminThemeController.prototype.bindEvents = function() {
    return this.resetLinks.on(
      'click',
      function(_this) {
        return function(event) {
          var defaultColor, input;
          input = _this.form.find('input[data-color-name=' + $(event.target).data('reset') + ']');
          defaultColor = input.data('default');
          if (!input.prop('disabled') && defaultColor) {
            input.val(defaultColor);
            $(input).colorpicker('setValue', defaultColor);
          }
          return event.preventDefault();
        };
      }(this)
    );
  };

  return InstanceAdminThemeController;
}();

module.exports = InstanceAdminThemeController;
