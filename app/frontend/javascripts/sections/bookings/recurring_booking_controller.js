var BookingsRecurringBookingController, Modal;

Modal = require('../../components/modal');

/*
 * Controller for handling recurring booking subset of booking module
 */
BookingsRecurringBookingController = function() {
  function BookingsRecurringBookingController(form) {
    this.form = form;
    this.weeklyRadioButton = this.form.find('[data-recurring-weekly]');
    this.RadioButton = this.form.find('[data-recurring-monthly]');
    this.recurringSelect = this.form.find('.recurring_select');
    this.firstTimeSelect = true;
    this.bindEvents();
  }

  BookingsRecurringBookingController.prototype.bindEvents = function() {
    this.weeklyRadioButton.on(
      'change',
      function(_this) {
        return function() {
          if (_this.weeklyRadioButton.prop('checked')) {
            return _this.changeRecurringSelect('Weekly', _this.weeklyRadioButton);
          }
        };
      }(this)
    );
    this.customRadioButton.on(
      'change',
      function(_this) {
        return function() {
          if (_this.customRadioButton.prop('checked')) {
            return _this.changeRecurringSelect('Custom', _this.customRadioButton);
          }
        };
      }(this)
    );
    this.recurringSelect.on(
      'recurring_select:cancel',
      function(_this) {
        return function() {
          _this.weeklyRadioButton.prop('checked', false).change();
          return _this.customRadioButton.prop('checked', false).change();
        };
      }(this)
    );
    return this.recurringSelect.on(
      'recurring_select:save',
      function(_this) {
        return function(event, form_data) {
          _this.form.find('.occurrences').val(form_data.occurrences);
          _this.form.find('.start_on').val(form_data.start_on);
          _this.form.find('.end_on').val(form_data.end_on);
          _this.form.find('.start_minute').val(form_data.start_at);
          _this.form.find('.end_minute').val(form_data.end_at);
          _this.form.find('.quantity').val(1);
          return _this.form.submit();
        };
      }(this)
    );
  };

  BookingsRecurringBookingController.prototype.changeRecurringSelect = function(text) {
    var option;
    if (this.form.data('registration-url')) {
      Modal.load(this.form.data('registration-url'));
      this.weeklyRadioButton.prop('checked', false).change();
      return this.customRadioButton.prop('checked', false).change();
    } else {
      if (this.firstTimeSelect) {
        this.recurringSelect.trigger('focus');
        this.firstTimeSelect = false;
      }
      option = this.recurringSelect.find('option').filter(function() {
        return $(this).text().indexOf(text, 0) > -1;
      });
      option.prop('selected', true);
      this.recurringSelect.trigger('change');
      return this.updateRecurringForm();
    }
  };

  /*
   * This function is used to populated the upsell charges into the recurringForm
   */
  BookingsRecurringBookingController.prototype.updateRecurringForm = function() {
    this.recurringDialog = $('.rs_dialog_content');
    return this.updateAdditionalCharges();
  };

  BookingsRecurringBookingController.prototype.updateAdditionalCharges = function() {
    var additionalChargeCheckboxes,
      additionalChargesArea,
      recurringBookingFormSummary,
      recurringChargesArea;
    additionalChargesArea = $('#additional_charges');
    recurringChargesArea = $('.recurring-booking form #recurring-charges');
    recurringBookingFormSummary = this.recurringDialog.find('.rs_summary');
    recurringBookingFormSummary.before(additionalChargesArea.clone());
    recurringChargesArea.append(additionalChargesArea.find('input[type=checkbox]').clone());

    /*
     * Binding event that will copy all of the updated checkboxes with charges to the main recurring form
     */
    additionalChargeCheckboxes = this.recurringDialog.find(
      '#additional_charges input[type=checkbox]'
    );
    return additionalChargeCheckboxes.on('change', function() {
      var additionalChargeFields;
      additionalChargeFields = $('.rs_dialog_content #additional_charges input[type=checkbox');
      recurringChargesArea.empty();
      return recurringChargesArea.append(additionalChargeFields.clone());
    });
  };

  return BookingsRecurringBookingController;
}();

module.exports = BookingsRecurringBookingController;
