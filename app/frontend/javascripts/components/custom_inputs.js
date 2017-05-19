var CHECKBOX_HTML,
  CustomInputs,
  RADIO_HTML,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

CHECKBOX_HTML = "<span class='checkbox-icon-outer'><span class='checkbox-icon-inner'></span></span>";

RADIO_HTML = "<span class='radio-icon-outer'><span class='radio-icon-inner'></span></span>";

CustomInputs = function() {
  function CustomInputs(context) {
    if (context == null) {
      context = 'body';
    }
    this.updateControls = bind(this.updateControls, this);
    this.context = $(context);
    this.body = $('body');
    this.buildElements();
    this.updateControls();
    if (!this.context.data('custom-inputs-initialized')) {
      this.bindEvents();
    }
    this.context.data('custom-inputs-initialized', true);
  }

  CustomInputs.prototype.buildElements = function() {
    console.log('CustomInputs :: buildElements');
    this.context
      .find('.checkbox')
      .not('[data-custom-input-initialized]')
      .attr('data-custom-input-initialized', 'true')
      .each(function(index, element) {
        return $(element).prepend(CHECKBOX_HTML);
      });
    return this.context
      .find('.radio')
      .not('[data-custom-input-initialized]')
      .attr('data-custom-input-initialized', 'true')
      .each(function(index, element) {
        return $(element).prepend(RADIO_HTML);
      });
  };

  CustomInputs.prototype.bindEvents = function() {
    this.body.on(
      'change.customInputs.nearme',
      '.checkbox, .radio, .checkbox input, .radio input',
      this.updateControls
    );
    this.body.on(
      'click.customInputs.nearme',
      '.radio-icon-outer',
      function(_this) {
        return function(event) {
          var customInput, input, label;
          customInput = $(event.target).closest('.radio');
          input = customInput.find('input[type="radio"]:not(:disabled)');
          label = customInput.find('label');
          label.trigger('click');
          input.triggerHandler('change');
          return _this.updateControls();
        };
      }(this)
    );
    return this.body.on(
      'click.customInputs.nearme',
      '.checkbox-icon-outer',
      function(_this) {
        return function(event) {
          var customInput, input;
          customInput = $(event.target).closest('.checkbox');
          input = customInput.find('input[type="checkbox"]:not(:disabled)');
          input.prop('checked', !input.prop('checked')).triggerHandler('change');
          return _this.updateControls();
        };
      }(this)
    );
  };

  CustomInputs.prototype.updateControls = function() {
    return this.context
      .find('.checkbox input[type="checkbox"], .radio input[type="radio"]')
      .each(function(index, element) {
        var $this;
        $this = $(element);
        return $this
          .closest('.checkbox, .radio')
          .toggleClass('checked', $this.is(':checked'))
          .toggleClass('disabled', $this.is(':disabled'));
      });
  };

  return CustomInputs;
}();

module.exports = CustomInputs;
