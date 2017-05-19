/* global google */
var AddressComponentParser,
  AddressField,
  Geocoder,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

Geocoder = require('../search/geocoder');

AddressComponentParser = require('./address_component_parser');

/*
 * Wrapper for the address and geolocation fields.
 *
 * Provides an autocomplete on the address field, and sets the location geolocation
 * fields (lat, long, address, etc.) on the form.
 */
AddressField = function() {
  function AddressField(input) {
    this.input = input;
    this.markerMoved = bind(this.markerMoved, this);
    this.getAutocompleteOptions = bind(this.getAutocompleteOptions, this);
    this.inputWrapper = this.input.closest('[data-address-field]');
    this.autocomplete = new google.maps.places.Autocomplete(
      this.input[0],
      this.getAutocompleteOptions()
    );
    this.addressComponentParser = new AddressComponentParser(this.inputWrapper);
    this.inputChanged = false;
    google.maps.event.addListener(
      this.autocomplete,
      'place_changed',
      function(_this) {
        return function() {
          var place;
          place = Geocoder.wrapResult(_this.autocomplete.getPlace());
          if (!place.isValid()) {
            place = null;
          }
          if (place) {
            return _this.pickSuggestion(place);
          }
        };
      }(this)
    );
    this.input.focus(
      function(_this) {
        return function() {
          _this.picked_result = false;
          return _this.inputChanged = false;
        };
      }(this)
    );
    this.input.change(
      function(_this) {
        return function() {
          return _this.inputChanged = true;
        };
      }(this)
    );
    this.input.blur(
      function(_this) {
        return function() {
          var geocoder;
          geocoder = new Geocoder();
          return setTimeout(
            function() {
              /*
           * If the blur ocurred without the selection of a result and the input changed then we want to
           * autocomplete to the first item in the autocomplete list if present and if the autocomplete
           * list is not present we set the map to the default place
           */
              var deferred, first_item, query;
              if (!_this.picked_result && _this.inputChanged) {
                if ($('.pac-container').find('.pac-item').length > 0 && _this.input.val() !== '') {
                  geocoder = new Geocoder();
                  first_item = $('.pac-container').find('.pac-item').eq(0);
                  query = first_item.find('.pac-item-query').eq(0).text() + ', ' +
                    first_item.find('> span').eq(-1).text();
                  deferred = geocoder.geocodeAddress(query);
                  return deferred.done(function(resultset) {
                    var result;
                    result = Geocoder.wrapResult(resultset.getBestResult().result);
                    _this.input.val(query);
                    return _this.pickSuggestion(result);
                  });
                } else {
                  _this.setLatLng(null, null);
                  _this.inputWrapper.find('[data-formatted-address]').val(null);
                  _this.inputWrapper.find('[data-local-geocoding]').val('1');
                  _this.input.parent().find('.address_components_input').remove();
                  if (_this._onLocate) {
                    return _this._onLocate(null, null);
                  }
                }
              }
            },
            200
          );
        };
      }(this)
    );
  }

  AddressField.prototype.getAutocompleteOptions = function() {
    var options, restrictCountries;
    options = {};
    restrictCountries = this.input.data('restrict-countries');
    if (restrictCountries && restrictCountries.length > 0) {
      options['componentRestrictions'] = { country: restrictCountries };
    }
    return options;
  };

  AddressField.prototype.markerMoved = function(lat, lng) {
    return setTimeout(
      function(_this) {
        return function() {
          var deferred, geocoder;
          geocoder = new Geocoder();
          deferred = geocoder.reverseGeocodeLatLng(lat, lng);
          return deferred.done(function(resultset) {
            var result;
            result = Geocoder.wrapResult(resultset.getBestResult().result);
            _this.input.val(result.formattedAddress());
            return _this.pickSuggestion(result);
          });
        };
      }(this),
      200
    );
  };

  AddressField.prototype.bump = function() {
    if (
      this.inputWrapper.find('[data-latitude]').val() &&
        this.inputWrapper.find('[data-longitude]').val()
    ) {
      return this.setLatLngWithCallback(
        this.inputWrapper.find('[data-latitude]').val(),
        this.inputWrapper.find('[data-longitude]').val()
      );
    }
  };

  AddressField.prototype.onLocate = function(callback) {
    return this._onLocate = callback;
  };

  AddressField.prototype.pickSuggestion = function(place) {
    this.picked_result = true;
    this.setLatLng(place.lat(), place.lng());
    this.inputWrapper.find('[data-formatted-address]').val(place.formattedAddress());
    this.inputWrapper.find('[data-local-geocoding]').val('1');
    this.addressComponentParser.buildAddressComponentsInputs(place);
    if (this._onLocate) {
      return this._onLocate(place.lat(), place.lng());
    }
  };

  /*
   * Used by map controllers to update the lat-lng by moving map marker.
   */
  AddressField.prototype.setLatLng = function(lat, lng) {
    this.inputWrapper.find('[data-latitude]').val(lat);
    return this.inputWrapper.find('[data-longitude]').val(lng);
  };

  AddressField.prototype.setLatLngWithCallback = function(lat, lng) {
    this.setLatLng(lat, lng);
    if (this._onLocate) {
      return this._onLocate(lat, lng);
    }
  };

  return AddressField;
}();

module.exports = AddressField;
