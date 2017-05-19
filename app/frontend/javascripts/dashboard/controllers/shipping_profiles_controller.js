var ShippingProfilesController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('selectize/dist/js/selectize');

ShippingProfilesController = function() {
  function ShippingProfilesController(el) {
    this.modalSuccessActions = bind(this.modalSuccessActions, this);
    this.form = $(el);
    this.countriesInput = this.form.find('select');
    this.worldwideCheckbox = this.form.find('[data-worldwide]');
    this.bindEvents();
    this.initializeSelectize();
    this.modalSuccessActions();
  }

  ShippingProfilesController.prototype.bindEvents = function() {
    this.form.on('change', '[data-shippo-for-price]', function(e) {
      if ($(e.target).is(':checked')) {
        return $(e.target)
          .closest('.shipping-form')
          .find('[data-price-field]')
          .prop('disabled', true);
      } else {
        return $(e.target)
          .closest('.shipping-form')
          .find('[data-price-field]')
          .prop('disabled', false);
      }
    });
    this.form.on('change', '[data-worldwide]', function(e) {
      if ($(e.target).is(':checked')) {
        return $(e.target).closest('.shipping-form').find('select')[0].selectize.disable();
      } else {
        return $(e.target).closest('.shipping-form').find('select')[0].selectize.enable();
      }
    });
    return $(document).on(
      'cocoon:after-insert',
      function(_this) {
        return function(e, insertedItem) {
          return _this.initializeSelectize(insertedItem);
        };
      }(this)
    );
  };

  ShippingProfilesController.prototype.initializeSelectize = function(container) {
    return $(container).find('select[multiple=multiple]').selectize();
  };

  ShippingProfilesController.prototype.modalSuccessActions = function() {
    if (!this.form.data('profile-add-success')) {
      return;
    }
    $(document).trigger('hide:dialog.nearme');
    return $.ajax({
      type: 'get',
      url: '/dashboard/shipping_profiles/get_shipping_profiles_list',
      data: { form: 'transactables' },
      success: function(data) {
        return $('[data-shipping-methods-list]').html(data);
      }
    });
  };

  return ShippingProfilesController;
}();

module.exports = ShippingProfilesController;
