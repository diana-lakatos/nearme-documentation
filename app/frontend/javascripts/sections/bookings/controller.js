/*
 * Controller for handling all of the booking selection logic on a Space page
 *
 * The controller is initialized with the bookings DOM container, and an options hash including
 * JS objects representing each Listing on the Location.
 */
var BookingsController, BookingsDatepicker, BookingsListing, Modal, UtilUrl;

BookingsListing = require('./listing');

BookingsDatepicker = require('./datepicker');

require('jquery.customSelect/jquery.customSelect');

require('select2/select2');

Modal = require('../../components/modal');

UtilUrl = require('../../lib/utils/url');

BookingsController = function() {
  function BookingsController(container, options1) {
    this.container = container;
    this.options = options1 != null ? options1 : {};
    this.container = $(this.container);
    this.activateFirstAvailableTab();
    this.listingData = this.container.data('listing');
    if ($.isEmptyObject(this.listingData.initial_bookings)) {
      this.listingData.initial_bookings = null;
    }
    this.submitFormImmediately = this.container.data('returned-from-session');
    this.setupDelayedMethods();
    this.listing = new BookingsListing(this.listingData, this.container);
    this.bindDomElements();
    if (this.listing.withCalendars()) {
      this.initializeDatepicker();
      this.listing.setDates(this.datepicker.getDates());
    }
    this.bindEvents();
    this.listing.currentPricingId = this.transactablePricing.val();
    if (!this.listing.withCalendars() && this.fixedPriceSelect.length > 0) {
      this.initializeInfiniScroll();
    }
    this.updateQuantityField();
    this.initializeCtaButton();
    if (this.listingData.initial_bookings && this.submitFormImmediately) {
      if (this.submitFormImmediately === 'RFQ') {
        this.rfqBooking();
      } else {
        this.reviewBooking();
      }
    }
    if (this.listing.onlyRfqAction()) {
      return;
    }
    this.updateSummary();
    this.delayedUpdateBookingStatus();
    if (!this.listing.isPerUnitBooking()) {
      this.quantityField.customSelect();
    }
  }

  /*
   * We need to set up delayed methods per each instance, not the prototype.
   * Otherwise, it will debounce for any instance calling the method.
   */
  BookingsController.prototype.setupDelayedMethods = function() {
    /*
     * A deferred version of the booking status view updating, so we don't
     * execute it multiple times in a short span of time.
     */
    return this.delayedUpdateBookingStatus = _.debounce(
      function() {
        return this.updateBookingStatus();
      },
      5
    );
  };

  /*
   * Bind to the various DOM elements managed by this controller.
   */
  BookingsController.prototype.bindDomElements = function() {
    this.transactablePricing = this.container.find('input[name="order[transactable_pricing_id]"]');
    this.quantityField = this.container.find('[name=quantity].quantity');
    this.bookItOutContainer = this.container.find('.book-it-out');
    this.bookItOutCheck = this.container.find('input[name="order[book_it_out]"]');
    this.exclusivePriceContainer = this.container.find('.exclusive-price');
    this.exclusivePriceCheck = this.exclusivePriceContainer.find('input');
    this.exclusivePriceContent = this.container.find('div[data-exclusive-price-content]');
    this.bookItOutTotal = this.bookItOutContainer.find('.discount_price span');
    this.quantityResourceElement = this.container.find('.quantity .resource');
    this.totalElement = this.container.find('.book .price .total');
    this.daysElement = this.container.find('.total-days');
    this.additionalCharges = this.container.find('[data-optional-charge-select]');
    this.bookButton = this.container.find('[data-behavior=reviewBooking]');
    this.rfqButton = this.container.find('[data-behavior=RFQ]');
    this.bookForm = this.bookButton.closest('form');
    this.registrationUrl = this.bookButton.data('registration-url');
    this.securedDomain = this.bookButton.data('secured');
    this.storeReservationRequestUrl = this.bookButton.data('store-reservation-request-url');
    this.userSignedIn = this.bookButton.data('user-signed-in');
    this.bookingTabs = this.container.find('[data-pricing-tabs] li a');
    if (!this.listing.withCalendars()) {
      this.fixedPriceSelect = this.container.find('[data-fixed-date-select]');
      this.fixedPriceSelectInit = this.fixedPriceSelect.data('init-value');
      this.fixedPriceSelect.on(
        'change',
        function(_this) {
          return function() {
            _this.updateBookingStatus();
            if (_this.listing.bookItOutAvailable()) {
              _this.updateBookItOut();
            }
            if (_this.listing.exclusivePriceAvailable()) {
              return _this.exclusivePrice();
            }
          };
        }(this)
      );
    }
    return this.setReservationType();
  };

  BookingsController.prototype.bindEvents = function() {
    this.bookingTabs.on(
      'shown.bs.tab',
      function(_this) {
        return function(event) {
          _this.listing.currentPricingId = $(event.target).parents('li').data('pricing-id');
          _this.listing.setHourlyBooking(_this.hourlyBookingSelected());
          _this.datepicker.setDates(_this.listing.bookedDatesArray);
          _this.setReservationType();
          return _this.updateBookingStatus();
        };
      }(this)
    );
    this.bookButton.on(
      'click',
      function(_this) {
        return function() {
          return _this.formTrigger = _this.bookButton;
        };
      }(this)
    );
    this.rfqButton.on(
      'click',
      function(_this) {
        return function() {
          return _this.formTrigger = _this.rfqButton;
        };
      }(this)
    );
    this.bookForm.on(
      'submit',
      function(_this) {
        return function(event) {
          event.preventDefault();
          if (_this.formTrigger === _this.bookButton) {
            return _this.reviewBooking();
          } else {
            return _this.rfqBooking();
          }
        };
      }(this)
    );
    this.quantityField.on(
      'change paste keyup',
      function(_this) {
        return function() {
          return _this.quantityWasChanged();
        };
      }(this)
    );
    this.additionalCharges.on(
      'change',
      function(_this) {
        return function() {
          _this.delayedUpdateBookingStatus();
          return _this.updateCharges();
        };
      }(this)
    );
    this.bookItOutContainer.on(
      'change',
      'input',
      function(_this) {
        return function(event) {
          return _this.bookItOut(event.target);
        };
      }(this)
    );
    this.exclusivePriceCheck.on(
      'change',
      function(_this) {
        return function() {
          return _this.exclusivePrice();
        };
      }(this)
    );
    if (this.listing.withCalendars()) {
      this.datepicker.bind(
        'datesChanged',
        function(_this) {
          return function(dates) {
            _this.listing.setDates(dates);
            _this.updateQuantityOptions(_this.listing.maxQuantityForSelectedDates());
            return _this.delayedUpdateBookingStatus();
          };
        }(this)
      );
      this.datepicker.bind(
        'timesChanged',
        function(_this) {
          return function() {
            return _this.updateTimesFromTimePicker();
          };
        }(this)
      );
    }
    if (this.exclusivePriceCheck.data('force-check') === 1) {
      this.exclusivePriceCheck.on('change', function() {
        /*
         * do not allow to uncheck
         */
        return $(this).prop('checked', true);
      });
      return this.exclusivePriceCheck.trigger('change');
    }
  };

  /*
  * Disable options in quantity select that are not available.
  */
  BookingsController.prototype.updateQuantityOptions = function(maxQuantity) {
    var isDisabled;
    var ref = this.quantityField.find('option');
    for (var i = 0; i < ref.length; i++) {
      var option = ref[i];
      isDisabled = parseInt(option.value) > maxQuantity;
      $(option).prop('disabled', isDisabled);
    }
  };

  BookingsController.prototype.activateFirstAvailableTab = function() {
    return this.container.find('.pricing-tabs a.possible:first').tab('show');
  };

  BookingsController.prototype.setReservationType = function() {
    if (this.hourlyBookingSelected()) {
      return this.bookForm.find('.reservation_type').val('hourly');
    } else {
      return this.bookForm.find('.reservation_type').val('daily');
    }
  };

  BookingsController.prototype.hourlyBookingSelected = function() {
    return this.container.find("li[data-unit='hour']").hasClass('active');
  };

  /*
   * Setup the datepicker for the simple booking UI
   */
  BookingsController.prototype.initializeDatepicker = function() {
    return this.datepicker = new BookingsDatepicker({
      listing: this.listing,
      container: this.container,
      listingData: this.listingData
    });
  };

  BookingsController.prototype.updateTimesFromTimePicker = function() {
    return this.updateBookingStatus();
  };

  /*
   * Update the view to display pricing, date selections, etc. based on
   * current selected dates.
   */
  BookingsController.prototype.updateBookingStatus = function() {
    this.transactablePricing.val(this.listing.currentPricingId);
    if (this.fixedPriceSelect) {
      if (this.fixedPriceSelect.val()) {
        this.listing.bookedDatesArray = [ this.fixedPriceSelect.val() ];
        this.listing.bookedDateAvailability = (this.fixedPriceSelect.select2('data') ||
          this.fixedPriceSelectInit).availability;
        if (!this.listing.isPerUnitBooking()) {
          this.updateQuantityOptions(this.listing.fixedAvailability());
          if (
            parseInt(this.quantityField.find('option:selected').val(), 10) >
              this.listing.fixedAvailability()
          ) {
            this.quantityField.val('' + this.listing.fixedAvailability());
            this.quantityField.trigger('change');
          }
        }
      } else {
        this.listing.bookedDatesArray = [];
      }
    } else {
      this.updateSummary();
    }
    if (!this.listing.isBooked()) {
      this.bookButton.addClass('disabled');
      this.bookButton.removeAttr('data-disable-with');
      return this.bookButton.tooltip();
    } else {
      this.bookButton.removeClass('disabled');
      this.bookButton.attr('data-disable-with', 'Processing ...');
      return this.bookButton.tooltip('destroy');
    }
  };

  BookingsController.prototype.quantityWasChanged = function(quantity) {
    if (quantity == null) {
      quantity = this.quantityField.val();
    }
    if (quantity.replace) {
      quantity = quantity.replace(',', '.');
    }
    this.listing.setDefaultQuantity(parseFloat(quantity, 10));
    if (!this.listing.isPerUnitBooking()) {
      this.updateQuantityField();
    }

    /*
     * Reset the datepicker if the booking is no longer available
     * with the new quantity.
     */
    if (this.listing.withCalendars()) {
      if (!this.listing.bookingValid()) {
        this.datepicker.reset();
      }
    }
    return this.updateSummary();
  };

  BookingsController.prototype.updateQuantityField = function(qty) {
    if (qty == null) {
      qty = this.listing.defaultQuantity;
    }
    if (!this.listing.isPerUnitBooking()) {
      this.container.find('.customSelect.quantity .customSelectInner').text(qty);
    }
    this.quantityField.val(qty);
    if (qty > 1) {
      return this.quantityResourceElement.text(this.quantityResourceElement.data('plural'));
    } else {
      return this.quantityResourceElement.text(this.quantityResourceElement.data('singular'));
    }
  };

  BookingsController.prototype.updateCharges = function() {
    var additionalChargeFields, reservationRequestForm;
    additionalChargeFields = this.container.find(
      "[data-additional-charges] input[name='order[additional_charge_ids][]']"
    );
    reservationRequestForm = this.container.find('[data-reservation-charges]');
    reservationRequestForm.empty();
    return additionalChargeFields.clone().prependTo(reservationRequestForm);
  };

  BookingsController.prototype.updateSummary = function() {
    var price;
    price = this.listing.bookingSubtotal(this.bookItOutSelected(), this.exclusivePriceSelected());
    return this.totalElement.text((price / this.listing.data.subunit_to_unit_rate).toFixed(2));
  };

  BookingsController.prototype.reviewBooking = function() {
    if (!this.listing.isBooked()) {
      return;
    }
    this.setFormFields();
    if (this.userSignedIn) {
      return this.bookForm.unbind('submit').submit();
    } else {
      return this.storeFormFields();
    }
  };

  BookingsController.prototype.rfqBooking = function() {
    this.setFormFields();
    if (this.userSignedIn) {
      return Modal.load(
        {
          type: this.rfqButton.data('modal-method'),
          url: this.rfqButton.data('modal-url'),
          data: this.bookForm.serialize()
        },
        null,
        false,
        function(_this) {
          return function() {
            $.rails.enableFormElement(_this.bookButton);
            return $.rails.enableFormElement(_this.rfqButton);
          };
        }(this)
      );
    } else {
      return this.storeFormFields();
    }
  };

  BookingsController.prototype.setFormFields = function() {
    var data_guest_notes, options;
    options = this.listing.reservationOptions();
    this.bookForm.find('[name="order[quantity]"]').val(options.quantity);
    this.bookForm
      .find('[name="order[book_it_out]"]')
      .val(options.book_it_out || this.bookItOutSelected());
    this.bookForm
      .find('[name="order[exclusive_price]"]')
      .val(options.exclusive_price || this.exclusivePriceSelected());
    data_guest_notes = this.container.find('[data-guest-notes]');
    this.bookForm.find('[name="order[dates]"]').val(options.dates);
    if (data_guest_notes && data_guest_notes.is(':visible')) {
      this.bookForm
        .find('[name="order[guest_notes]"]')
        .val(options.guest_notes || data_guest_notes.val());
    }
    if (this.listing.withCalendars()) {
      this.bookForm.find('[name="order[start_on]"]').val(options.start_on);
      this.bookForm.find('[name="order[end_on]"]').val(options.end_on);
      if (this.listing.isReservedHourly()) {
        this.bookForm.find('[name="order[start_minute]"]').val(options.start_minute);
        return this.bookForm.find('[name="order[end_minute]"]').val(options.end_minute);
      }
    }
  };

  BookingsController.prototype.storeFormFields = function() {
    return $.post(
      this.storeReservationRequestUrl,
      this.bookForm.serialize() + ('&commit=' + this.formTrigger.data('behavior')),
      function(_this) {
        return function() {
          if (_this.securedDomain) {
            return Modal.load(_this.registrationUrl);
          } else {
            return window.location.replace(_this.registrationUrl);
          }
        };
      }(this)
    );
  };

  BookingsController.prototype.bookItOutSelected = function() {
    return this.listing.bookItOutAvailable() && this.bookItOutCheck.is(':checked');
  };

  BookingsController.prototype.updateBookItOut = function() {
    if (this.listing.bookItOutAvailableForDate()) {
      this.bookItOutContainer.show();
      return this.bookItOutTotal.text('-' + this.listing.bookItOutDiscount() + ' %');
    } else {
      return this.bookItOutContainer.hide();
    }
  };

  BookingsController.prototype.bookItOut = function(element) {
    var i, len, option, ref;
    if ($(element).is(':checked')) {
      this.exclusivePriceCheck.prop('checked', false).trigger('change');

      /*
       * @bookItOutTotal.parents('.discount_price').hide()
       */
      this.totalElement.text(
        (this.listing.bookItOutSubtotal() / this.listing.data.subunit_to_unit_rate).toFixed(2)
      );
      this.quantityWasChanged(this.listing.bookItOutMin());
      ref = this.quantityField.find('option');
      for (i = 0, len = ref.length; i < len; i++) {
        option = ref[i];
        if (parseInt(option.value) < this.listing.bookItOutMin()) {
          $(option).prop('disabled', true);
        } else {
          $(option).prop('disabled', false);
        }
      }
      return this.updateQuantityField();
      /*
       * @quantityField.prop('disabled', true)
       */
    } else {
      /*
       * @bookItOutTotal.parents('.discount_price').show()
       */
      this.quantityField.find('option').prop('disabled', false);

      /*
       * @quantityField.prop('disabled', false)
       */
      return this.quantityWasChanged(1);
    }
  };

  BookingsController.prototype.exclusivePriceSelected = function() {
    return this.listing.exclusivePriceAvailable() &&
      (this.exclusivePriceCheck.is(':checked') ||
        this.exclusivePriceCheck.data('force-check') === 1);
  };

  BookingsController.prototype.exclusivePrice = function() {
    if (this.exclusivePriceSelected()) {
      this.bookItOutCheck.prop('checked', false).trigger('change');
      this.exclusivePriceContainer.find('.discount_price').hide();
      this.quantityField.prop('disabled', true);
      this.container.find('div.quantity').hide();
      if (this.exclusivePriceContent) {
        this.exclusivePriceContent.show();
      }
      return this.updateSummary();
    } else {
      this.container.find('div.quantity').show();
      this.exclusivePriceContainer.find('.discount_price').show();
      this.quantityField.prop('disabled', false);
      if (this.exclusivePriceContent) {
        this.exclusivePriceContent.hide();
      }
      return this.updateSummary();
    }
  };

  BookingsController.prototype.initializeInfiniScroll = function() {
    var endDate, startDate;
    startDate = UtilUrl.getParameterByName('start_date');
    endDate = UtilUrl.getParameterByName('end_date');
    this.fixedPriceSelect.select2({
      placeholder: 'Select date',
      ajax: {
        url: '/listings/' + this.listing.getId() + '/occurrences',
        dataType: 'json',
        data: function(term, page) {
          return {
            q: term,
            page: page,
            last_occurrence: $(this).data('last_occurrence'),
            start_date: startDate !== '' ? new Date(startDate).toDateString() : void 0,
            end_date: endDate !== '' ? new Date(endDate).toDateString() : void 0
          };
        },
        results: function(_this) {
          return function(data) {
            var more;
            more = data.length === 10;
            if (data.length > 0) {
              _this.fixedPriceSelect.data('last_occurrence', data.slice(-1)[0].id);
            }
            return { results: data, more: more };
          };
        }(this),
        cache: true
      },
      minimumResultsForSearch: -1,
      formatLoadMore: 'Loading...',
      formatNoMatches: 'No dates found',
      escapeMarkup: function(m) {
        return m;
      }
    });
    this.container.find('.select2-chosen').text(this.fixedPriceSelectInit.text);
    this.fixedPriceSelect.val(this.fixedPriceSelectInit.id);
    return this.fixedPriceSelect.trigger('change');
  };

  BookingsController.prototype.initializeCtaButton = function() {
    return this.bookButton.add(this.rfqButton).attr('disabled', false);
  };

  return BookingsController;
}();

module.exports = BookingsController;
