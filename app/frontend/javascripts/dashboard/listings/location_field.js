var AvailabilityRules,
  LimitedInput,
  LocationField,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

LimitedInput = require('../../components/limited_input');

AvailabilityRules = require('./availability_rules');

LocationField = function() {
  function LocationField(field) {
    this.bindEvents = bind(this.bindEvents, this);
    this.field = $(field);
    this.bindEvents();
    this.locationChanged();
  }

  LocationField.prototype.options = function() {
    return $('[data-location-actions] [data-location-id]');
  };

  LocationField.prototype.bindEvents = function() {
    this.field.on(
      'change',
      function(_this) {
        return function() {
          return _this.locationChanged();
        };
      }(this)
    );
    return $('html').on('loaded:dialog.nearme', function() {
      $('.dialog--loaded [data-counter-limit]').each(function(index, item) {
        return new LimitedInput(item);
      });
      return new AvailabilityRules('.dialog .listing-availability');
    });
  };

  LocationField.prototype.locationChanged = function() {
    var location_id, option;
    location_id = this.field.val();
    option = this.options().attr('hidden', true).filter('[data-location-id="' + location_id + '"]');
    option.removeAttr('hidden');
    return $('label[for="availability_rules_defer"] p').text($(option).data('availability'));
  };

  return LocationField;
}();

module.exports = LocationField;
