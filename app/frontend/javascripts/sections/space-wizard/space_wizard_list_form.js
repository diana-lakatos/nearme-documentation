var CustomInputs,
  CustomSelects,
  SpaceWizardSpaceForm,
  jstz,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

CustomInputs = require('../../components/custom_inputs');

CustomSelects = require('../../components/custom_selects');

jstz = require('exports?jstz!jstimezonedetect/dist/jstz');

SpaceWizardSpaceForm = function() {
  function SpaceWizardSpaceForm(container) {
    this.container = container;
    this.successfulValidationHandler = bind(this.successfulValidationHandler, this);
    this.bindCocoonEvents = bind(this.bindCocoonEvents, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.bindCocoonEvents();

    /*
     * THIS CODE IS COMMENTED BECAUSE CLIENT_SIDE_VALIDATION 3.2.5 GEM IS NOT STABLE AT THE TIME BEING.
     * 3.2.5 version does not validate nested inputs [ listing fields ], version 3.2.1 validates listing fields,
     * but does not validate company name.
     *
     * $('.custom-select').chosen()
     * @container.find('.control-group').addClass('input-disabled').find(':input').attr("disabled", true)
     * $(".custom-select").trigger("liszt:updated")
     *
     * @input_number = 0
     * @input_length = @container.find('.control-group').length
     *
     * @bindEvents()
     * @unlockInput()
     * comment the next line to disable control group disable
     *
     * This form has two submit buttons, this code stops rails unobtrusive js
     * from triggering both diasable_with text swaps.
     */
    $('.new_company :submit').click(function() {
      var buttons;
      buttons = $('.new_company :submit').not($(this));
      buttons.removeAttr('data-disable-with');
      return buttons.attr('disabled', true);
    });
    this.setDefaultTimezone();
  }

  SpaceWizardSpaceForm.prototype.unlockInput = function(with_focus) {
    var input;
    if (with_focus == null) {
      with_focus = true;
    }
    if (this.input_number < this.input_length) {
      input = this.container
        .find('> .control-group')
        .eq(this.input_number)
        .removeClass('input-disabled')
        .find(':input')
        .removeAttr('disabled')
        .eq(0);
      if (with_focus) {
        input.focus();
      }

      /*
       * hack to ignore currency chosen - just unlock the next field after chosen
       */
      if (
        this.container
          .find('> .control-group')
          .eq(this.input_number)
          .find('.custom-select').length >
          0
      ) {
        this.container
          .find('> .control-group')
          .eq(this.input_number)
          .find('.custom-select')
          .trigger('liszt:updated');
        this.input_number = this.input_number + 1;
        return this.unlockInput();
      }
    }
  };

  SpaceWizardSpaceForm.prototype.bindEvents = function() {
    /*
     * Progress to the next form field when a selection is made from select elements
     */
    return this.container.on('change', 'select', function(event) {
      return $(event.target)
        .closest('.control-group')
        .next()
        .removeClass('input-disabled')
        .find(':input')
        .removeAttr('disabled')
        .focus();
    });
  };

  SpaceWizardSpaceForm.prototype.bindCocoonEvents = function() {
    this.container
      .find('.custom-availability-rules')
      .on('cocoon:before-remove', function(e, fields) {
        return $(fields)
          .closest('.nested-container')
          .find('.transactable_availability_template_availability_rules__destroy input')
          .val('true');
      });
    return this.container
      .find('.custom-availability-rules')
      .on('cocoon:after-insert', function(e, fields) {
        return $(fields).each(function() {
          new CustomInputs(this);
          return new CustomSelects(this);
        });
      });
  };

  SpaceWizardSpaceForm.prototype.successfulValidationHandler = function(element) {
    var index;
    index = element.closest('.control-group').index();
    if (this.allValid()) {
      if (index > this.input_number) {
        this.input_number = index;
      } else {
        this.input_number = this.input_number + 1;
      }
      return this.unlockInput();
    }
  };

  SpaceWizardSpaceForm.prototype.allValid = function() {
    return this.container.find('.error-block').length === 0;
  };

  SpaceWizardSpaceForm.prototype.setDefaultTimezone = function() {
    var timezone, tz;
    tz = jstz.determine().name();
    if (
      tz.length > 0 && $('select.time_zone').length > 0 && $('select.time_zone').val().length === 0
    ) {
      timezone = tz.split('/').pop();
      return $('select.time_zone').val(timezone);
    }
  };

  return SpaceWizardSpaceForm;
}();

module.exports = SpaceWizardSpaceForm;
