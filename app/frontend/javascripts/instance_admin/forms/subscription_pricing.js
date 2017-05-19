var SubscriptionPricing;

SubscriptionPricing = function() {
  function SubscriptionPricing() {
    this.initialize();
  }

  SubscriptionPricing.prototype.initialize = function() {
    this.unit_selects = $('[data-subscription-unit]');
    $('.nested-fields-set').on(
      'cocoon:after-insert',
      function(_this) {
        return function(e, insertedItem) {
          var insertedSelect;
          insertedSelect = $(insertedItem).find('[data-subscription-unit]');
          insertedSelect.on('change', function(event) {
            return _this.toggleProRata($(event.target));
          });
          return _this.toggleProRata(insertedSelect);
        };
      }(this)
    );
    this.unit_selects.on(
      'change',
      function(_this) {
        return function(event) {
          return _this.toggleProRata($(event.target));
        };
      }(this)
    );
    return this.unit_selects.each(
      function(_this) {
        return function(index, el) {
          return _this.toggleProRata($(el));
        };
      }(this)
    );
  };

  SubscriptionPricing.prototype.toggleProRata = function(select) {
    var proRata;
    proRata = select.parents('.row').find('[data-pro-rated]');
    if (select.val() === 'subscription_month') {
      return proRata.parents('.control-group').show();
    } else {
      return proRata.parents('.control-group').hide();
    }
  };

  return SubscriptionPricing;
}();

module.exports = SubscriptionPricing;
