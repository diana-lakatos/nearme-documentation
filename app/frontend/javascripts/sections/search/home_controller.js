var HomeController,
  SearchController,
  SearchDatepickers,
  SearchGeocoder,
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key))
        child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  },
  hasProp = {}.hasOwnProperty;

SearchController = require('./controller');

SearchDatepickers = require('./datepickers');

SearchGeocoder = require('./geocoder');

/*
 * Controller for search form on the homepage
 */
HomeController = function(superClass) {
  extend(HomeController, superClass);

  function HomeController(form, container1) {
    this.container = container1;
    this.form = $(form);
    this.transactableTypePicker = this.form.find('[data-transactable-type-picker]');
    this.transactableTypeClass = this.form.find("[name='transactable_type_class']");
    this.transactableTypeId = this.form.find("[name='transactable_type_id']");
    this.queryField = this.form.find('input[name="loc"]');
    this.initializeSearchForm();
    this.visibleFields = function(_this) {
      return function() {
        return _this.form.find('.transactable-type-search-box:visible');
      };
    }(this);
    this.visibleQueryField = function(_this) {
      return function() {
        return _this.visibleFields().find('input[name="loc"]:first');
      };
    }(this);
    this.keywordField = this.form.find('input[name="query"]');
    this.initializeGeolocateButton();
    this.initializeGeocoder();
    $.each(
      this.form.find('.transactable-type-search-box'),
      function(_this) {
        return function(idx, container) {
          var geo_input;
          new SearchDatepickers($(container));
          geo_input = $(container).find('input[name="loc"]');
          if (geo_input.length > 0) {
            _this.initializeAutocomplete(geo_input);
            return _this.initializeQueryField(geo_input);
          }
        };
      }(this)
    );
    if (
      this.queryField.length > 0 && this.form.find('.geolocation').data('enableGeoLocalization')
    ) {
      _.defer(
        function(_this) {
          return function() {
            return _this.geolocateMe();
          };
        }(this)
      );
    }
  }

  HomeController.prototype.assignFormParams = function(paramsHash) {
    /*
     * Write params to search form
     */
    var field, results, value;
    results = [];
    for (field in paramsHash) {
      value = paramsHash[field];
      if (field !== 'loc') {
        results.push(this.visibleFields().find("input[name='" + field + "']").val(value));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  HomeController.prototype.initializeQueryField = function(queryField) {
    queryField.bind('focus', function(event) {
      var input;
      input = $(event.target);
      if (input.val() === input.data('placeholder')) {
        input.val('');
      }
      return true;
    });
    queryField.bind('blur', function(event) {
      var input;
      input = $(event.target);
      if (input.val().length < 1 && input.data('placeholder') != null) {
        _.defer(function() {
          return input.val(input.data('placeholder'));
        });
      }
      return true;
    });

    /*
     * when submitting the form without clicking on autocomplete, we need to check if the field's value has been changed to update lat/lon and address components.
     * otherwise, no matter what we type in, we will always get results for geolocated address
     */
    return this.form.submit(
      function(_this) {
        return function(e) {
          var deferred;
          e.preventDefault();
          if (
            _this.visibleQueryField().length > 0 &&
              _this.visibleQueryField().val() !== _this.cached_geolocate_me_city_address
          ) {
            if (_this.visibleQueryField().val()) {
              _this.geocoder = new SearchGeocoder();
              deferred = _this.geocoder.geocodeAddress(_this.visibleQueryField().val());
              return deferred.always(function(resultset) {
                if (resultset != null) {
                  _this.setGeolocatedQuery(
                    _this.visibleQueryField().val(),
                    resultset.getBestResult()
                  );
                }
                return $(e.target).unbind('submit').submit();
              });
            } else {
              _this.setGeolocatedQuery(
                _this.cached_geolocate_me_city_address,
                _this.cached_geolocate_me_result_set
              );
              return $(e.target).unbind('submit').submit();
            }
          } else {
            return $(e.target).unbind('submit').submit();
          }
        };
      }(this)
    );
  };

  HomeController.prototype.initializeSearchForm = function() {
    if (this.transactableTypePicker.length > 0) {
      if (this.transactableTypePicker.filter(':checked').length > 0) {
        this.toggleTransactableTypes(this.transactableTypePicker.filter(':checked').val());
      } else {
        this.toggleTransactableTypes(this.transactableTypePicker.val());
      }
      return this.transactableTypePicker.bind(
        'change',
        function(_this) {
          return function(event) {
            return _this.toggleTransactableTypes($(event.target).val());
          };
        }(this)
      );
    }
  };

  HomeController.prototype.toggleTransactableTypes = function(tt_id) {
    var id, inputs, other_inputs;
    id = tt_id.split('-');
    this.transactableTypeClass.val(id[0]);
    this.transactableTypeId.val(id[1]);
    inputs = this.form.find("[data-transactable-type-id='" + tt_id + "']");
    other_inputs = this.form.find('.transactable-type-search-box');
    other_inputs.hide().find('input').prop('disabled', true);
    return inputs.show().find('input').prop('disabled', false);
  };

  return HomeController;
}(SearchController);

module.exports = HomeController;
