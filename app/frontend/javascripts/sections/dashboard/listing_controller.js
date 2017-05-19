var AvailabilityRulesController,
  DashboardListingController,
  PriceFields,
  SetupNestedForm,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

AvailabilityRulesController = require('../../components/availability_rules_controller');

SetupNestedForm = require('../setup_nested_form');

PriceFields = require('../../components/price_fields');

DashboardListingController = function() {
  function DashboardListingController(container) {
    this.container = container;
    this.changeBookingType = bind(this.changeBookingType, this);
    this.setupBookingType = bind(this.setupBookingType, this);
    this.updateCurrency = bind(this.updateCurrency, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.availabilityRules = new AvailabilityRulesController(this.container);
    this.currencySelect = this.container.find('#currency-select');
    this.locationRadios = this.container.find('#location-list input[type="radio"]');
    this.currencyHolders = this.container.find('.currency-holder');
    this.currencyLocationHolders = this.container.find('.currency_addon');
    this.defalt_currency = this.container.find('#default_currency').text();
    this.enableSwitch = this.container.find('#listing_enabled').parent().parent();
    this.enableAjaxUpdate = true;
    this.initializePriceFields();
    this.bindEvents();
    this.updateCurrency();
    this.setupDocumentRequirements();
  }

  DashboardListingController.prototype.bindEvents = function() {
    this.setupBookingType();
    this.container.on(
      'change',
      this.currencySelect,
      function(_this) {
        return function() {
          return _this.updateCurrency();
        };
      }(this)
    );
    this.setupTooltips();
    return this.enableSwitch.on(
      'switch-change',
      function(_this) {
        return function(e, data) {
          var enabled_should_be_changed_by_ajax, url, value;
          enabled_should_be_changed_by_ajax = _this.enableSwitch.data('ajax-updateable');
          if (enabled_should_be_changed_by_ajax != null) {
            value = data.value;
            if (_this.enableAjaxUpdate) {
              url = _this.container.attr('action');
              if (value) {
                url += '/enable';
              } else {
                url += '/disable';
              }
              return $.ajax({
                url: url,
                type: 'GET',
                dataType: 'JSON',
                error: function() {
                  _this.enableAjaxUpdate = false;
                  return _this.enableSwitch
                    .find('#listing_enabled')
                    .siblings('label')
                    .trigger('mousedown')
                    .trigger('mouseup')
                    .trigger('click');
                }
              });
            } else {
              return _this.enableAjaxUpdate = true;
            }
          }
        };
      }(this)
    );
  };

  DashboardListingController.prototype.setupTooltips = function() {
    if ($('.no_trust_explanation_needed').length > 0) {
      $(
        '.no_trust_explanation_needed .bootstrap-switch-wrapper'
      ).attr('data-original-title', $('.no_trust_explanation_needed').attr('data-explanation'));
      return $(
        '.no_trust_explanation_needed .bootstrap-switch-wrapper'
      ).tooltip({ trigger: 'hover' });
    }
  };

  DashboardListingController.prototype.updateCurrency = function() {
    this.currencyHolders.html(
      $('#currency_' + (this.currencySelect.val() || this.defalt_currency)).text()
    );
    return this.currencyLocationHolders.html(
      $('#currency_' + (this.currencySelect.val() || this.defalt_currency)).text()
    );
  };

  DashboardListingController.prototype.initializePriceFields = function() {
    this.priceFieldsFree = new PriceFields(this.container.find('.price-inputs-free:first'));
    this.priceFieldsHourly = new PriceFields(this.container.find('.price-inputs-hourly:first'));
    this.priceFieldsDaily = new PriceFields(this.container.find('.price-inputs-daily:first'));
    this.priceFieldsSubscription = new PriceFields(
      this.container.find('.price-inputs-subscription:first')
    );
    this.freeInput = this.container.find('.price-inputs-free').find('input:checkbox:first');
    this.dailyInput = this.container.find('.price-inputs-daily').find('input:checkbox:first');
    this.hourlyInput = this.container.find('.price-inputs-hourly').find('input:checkbox:first');
    this.subscriptionInput = this.container
      .find('.price-inputs-subscription')
      .find('input:checkbox:first');
    this.hideNotCheckedPriceFields();
    this.freeInput.on(
      'change',
      function(_this) {
        return function() {
          return _this.togglePriceFields();
        };
      }(this)
    );
    this.hourlyInput.on(
      'change',
      function(_this) {
        return function() {
          _this.freeInput.prop('checked', false);
          return _this.togglePriceFields();
        };
      }(this)
    );
    this.dailyInput.on(
      'change',
      function(_this) {
        return function() {
          _this.freeInput.prop('checked', false);
          return _this.togglePriceFields();
        };
      }(this)
    );
    return this.subscriptionInput.on(
      'change',
      function(_this) {
        return function() {
          _this.freeInput.prop('checked', false);
          return _this.togglePriceFields();
        };
      }(this)
    );
  };

  DashboardListingController.prototype.togglePriceFields = function() {
    if (this.freeInput.is(':checked')) {
      this.priceFieldsFree.show();
      this.dailyInput.prop('checked', false);
      this.hourlyInput.prop('checked', false);
      this.subscriptionInput.prop('checked', false);
    }
    if (this.hourlyInput.is(':checked')) {
      this.priceFieldsHourly.show();
    }
    if (this.dailyInput.is(':checked')) {
      this.priceFieldsDaily.show();
    }
    if (this.subscriptionInput.is(':checked')) {
      this.priceFieldsSubscription.show();
    }
    return this.hideNotCheckedPriceFields();
  };

  DashboardListingController.prototype.hideNotCheckedPriceFields = function() {
    if (!this.freeInput.is(':checked')) {
      this.priceFieldsFree.hide();
    }
    if (!this.hourlyInput.is(':checked')) {
      this.priceFieldsHourly.hide();
    }
    if (!this.dailyInput.is(':checked')) {
      this.priceFieldsDaily.hide();
    }
    if (!this.subscriptionInput.is(':checked')) {
      return this.priceFieldsSubscription.hide();
    }
  };

  DashboardListingController.prototype.setupDocumentRequirements = function() {
    var nestedForm;
    nestedForm = new SetupNestedForm(this.container);
    return nestedForm.setup(
      '.remove-document-requirement:not(:first)',
      '.document-hidden',
      '.remove-document',
      '.document-requirement',
      '.document-requirements .add-new',
      true
    );
  };

  DashboardListingController.prototype.setupBookingType = function() {
    var i, len, period, ref;
    this.periodInputs = {};
    this.allPeriodsLabel = $('div[data-all-periods-label]');
    this.dailyLabel = $('div[data-daily-label]');
    this.bookingTypeInput = $('input[data-booking-type]');
    ref = [ 'hourly', 'daily', 'weekly', 'monthly', 'subscription' ];
    for (i = 0, len = ref.length; i < len; i++) {
      period = ref[i];
      this.periodInputs[period] = this.container.find('div[data-period="' + period + '"]');
    }
    this.changeBookingType($('ul[data-booking-type-list] li.active a[data-toggle="tab"]'));
    return $('ul[data-booking-type-list] a[data-toggle="tab"]').on(
      'show.bs.tab',
      function(_this) {
        return function(e) {
          return _this.changeBookingType(e.target);
        };
      }(this)
    );
  };

  DashboardListingController.prototype.changeBookingType = function(target) {
    var bookingType;
    if ($(target).length > 0) {
      bookingType = $(target).attr('data-booking-type');
      this.bookingTypeInput.val(bookingType);
      if (bookingType === 'overnight') {
        this.periodInputs.hourly.hide();
      } else {
        this.periodInputs.hourly.show();
      }
      if (bookingType === 'recurring') {
        this.periodInputs.weekly.hide();
        this.periodInputs.monthly.hide();
        this.allPeriodsLabel.hide();
        return this.dailyLabel.show();
      } else {
        this.periodInputs.weekly.show();
        this.periodInputs.monthly.show();
        this.allPeriodsLabel.show();
        return this.dailyLabel.hide();
      }
    }
  };

  return DashboardListingController;
}();

module.exports = DashboardListingController;
