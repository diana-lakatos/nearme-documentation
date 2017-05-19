/* global google */
var Geocoder, slice = [].slice;

Geocoder = function() {
  var Result, ResultSet;

  ResultSet = function() {
    function ResultSet(results) {
      var i, len, result;
      this.results = [];
      for (i = 0, len = results.length; i < len; i++) {
        result = results[i];
        this.results.push(new Result(result));
      }
    }

    ResultSet.prototype.getBestResult = function() {
      return this.results[0];
    };

    ResultSet.prototype.getResults = function() {
      return this.results;
    };

    return ResultSet;
  }();

  Result = function() {
    function Result(result1) {
      this.result = result1;
    }

    Result.prototype.isValid = function() {
      return this.result.hasOwnProperty('geometry');
    };

    Result.prototype.postcode = function() {
      return this._componentLongName(this._addressComponentOfType('postal_code', 'political'));
    };

    Result.prototype.street = function() {
      return this._componentLongName(this._addressComponentOfType('route', 'political'));
    };

    Result.prototype.suburb = function() {
      return this._componentLongName(this._addressComponentOfType('sublocality', 'political'));
    };

    Result.prototype.city = function() {
      return this._componentLongName(this._addressComponentOfType('locality', 'political'));
    };

    Result.prototype.state = function() {
      return this._componentLongName(
        this._addressComponentOfType('administrative_area_level_1', 'political')
      );
    };

    Result.prototype.stateShort = function() {
      return this._componentLongName(
        this._addressComponentOfType('administrative_area_level_1', 'political')
      );
    };

    Result.prototype.country = function() {
      return this._componentLongName(this._addressComponentOfType('country', 'political'));
    };

    Result.prototype.cityAddress = function() {
      if (this.city()) {
        return this.city() + ', ' + this.country();
      }
    };

    Result.prototype.cityAndStateAddress = function() {
      var loc_components;
      loc_components = [];
      if (this.city()) {
        loc_components.push(this.city());
      }
      if (this.stateShort()) {
        loc_components.push(this.stateShort());
      }
      loc_components.push(this.country());
      return loc_components.join(', ');
    };

    Result.prototype.lat = function() {
      var loc;
      loc = this.result.geometry.location;
      if (loc) {
        return loc.lat();
      }
    };

    Result.prototype.lng = function() {
      var loc;
      loc = this.result.geometry.location;
      if (loc) {
        return loc.lng();
      }
    };

    Result.prototype.boundingBox = function() {
      var ne, sw, viewport;
      viewport = this.result.geometry.viewport;
      if (viewport) {
        sw = viewport.getSouthWest();
        ne = viewport.getNorthEast();
        return [ sw.lat(), sw.lng(), ne.lat(), ne.lng() ];
      }
    };

    Result.prototype.formattedAddress = function() {
      return this.result.formatted_address;
    };

    Result.prototype._addressComponentOfType = function() {
      var c, component, i, j, len, len1, match, ref, t, type, types;
      types = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      component = null;
      ref = this.result.address_components;
      for (i = 0, len = ref.length; i < len; i++) {
        c = ref[i];
        t = c.types;
        match = true;
        for (j = 0, len1 = types.length; j < len1; j++) {
          type = types[j];
          match = match && _.contains(t, type);
        }
        if (match) {
          component = c;
        }
      }
      return component;
    };

    Result.prototype._componentLongName = function(component) {
      if (component) {
        return component.long_name;
      }
    };

    return Result;
  }();

  /*
   * Return a wrapped geocoder/places API response result object
   */
  Geocoder.wrapResult = function(resultObject) {
    return new Result(resultObject);
  };

  function Geocoder() {
    this.geocoder = new google.maps.Geocoder();
  }

  /*
   * Geocode an address, returning a jQuery Defferred callback object.
   */
  Geocoder.prototype.geocodeAddress = function(address) {
    return this.geocodeWithOptions({ 'address': address });
  };

  /*
   * Reverse geocode from latlng coordinates
   */
  Geocoder.prototype.reverseGeocodeLatLng = function(lat_or_latlng, lng) {
    var latlng;
    if (lng == null) {
      lng = void 0;
    }
    if (lat_or_latlng instanceof google.maps.LatLng) {
      latlng = lat_or_latlng;
    } else {
      latlng = new google.maps.LatLng(lat_or_latlng, lng);
    }
    return this.geocodeWithOptions({ latLng: latlng });
  };

  Geocoder.prototype.geocodeWithOptions = function(options) {
    var deferred;
    deferred = jQuery.Deferred();
    this.geocoder.geocode(options, function(results, status) {
      if (status === google.maps.GeocoderStatus.OK) {
        return deferred.resolve(new ResultSet(results));
      } else {
        return deferred.reject();
      }
    });
    return deferred;
  };

  return Geocoder;
}();

module.exports = Geocoder;
