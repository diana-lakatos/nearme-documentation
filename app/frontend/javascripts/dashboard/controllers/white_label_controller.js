var WhiteLabelController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

WhiteLabelController = function() {
  function WhiteLabelController(form) {
    this.synchronize = bind(this.synchronize, this);
    this.form = $(form);
    this.whiteLabelSettingsEnabler = this.form.find('input[data-white-label-enabler]');
    this.whiteLabelCheckboxes = this.form.find('input[data-white-label-settings]');
    this.whiteLabelSettingsContainer = this.form.find('[data-white-label-settings-container]');
    this.resetLinksInit();
    this.bindEvents();
    this.synchronize();
  }

  WhiteLabelController.prototype.resetLinksInit = function() {
    return this.form.find('input[type="color"]').each(function(index, item) {
      var button, input;
      input = $(item);
      button = $(
        '<button type="button" data-reset class="action--remove" title="Reset to default">Reset</button>'
      );
      button.data('input', input);
      return input.after(button);
    });
  };

  WhiteLabelController.prototype.bindEvents = function() {
    this.whiteLabelSettingsEnabler.on(
      'change',
      function(_this) {
        return function() {
          return _this.synchronize();
        };
      }(this)
    );
    return this.form.on('click', '[data-reset]', function(e) {
      var input;
      input = $(e.target).closest('[data-reset]').data('input');
      if (!input.prop('disabled')) {
        return input.val(input.data('default'));
      }
    });
  };

  WhiteLabelController.prototype.synchronize = function() {
    this.whiteLabelSettingsContainer
      .find(
        'input[type=text], input[type=tel], input[type=email], input[type=url], input[type=color], input[type=file]'
      )
      .prop('disabled', !this.whiteLabelSettingsEnabler.is(':checked'));
    return this.whiteLabelCheckboxes.prop('checked', this.whiteLabelSettingsEnabler.is(':checked'));
  };

  return WhiteLabelController;
}();

module.exports = WhiteLabelController;
