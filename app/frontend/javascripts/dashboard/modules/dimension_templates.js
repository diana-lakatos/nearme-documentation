var DimensionTemplates,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('selectize/dist/js/selectize');

DimensionTemplates = function() {
  function DimensionTemplates(container, units) {
    this.updateUnits = bind(this.updateUnits, this);
    this.container = $(container);
    this.units = units;
    this.dimensions_templates_select = this.container.find(
      '[data-shipping-dimensions-templates-select]'
    );
    this.unit_of_measure = this.container.find('[data-shipping-unit-of-measure]');
    this.dimension_fields = this.prepareFields('shipping-dimension');
    this.unit_fields = this.prepareFields('shipping-dimension-unit');
    this.addTemplateTrigger = this.container.find('[data-add-template-trigger]');
    this.state = true;
    this.bindEvents();
    this.initialize();
  }

  DimensionTemplates.prototype.bindEvents = function() {
    this.dimensions_templates_select.on(
      'change',
      function(_this) {
        return function() {
          return _this.updateDimensionsFieldsFromTemplates();
        };
      }(this)
    );
    this.container.on(
      'toggle.dimensiontemplates',
      function(_this) {
        return function(e, state) {
          return _this.toggle(state);
        };
      }(this)
    );
    this.unit_of_measure.filter('select').on('change', this.updateUnits);
    return this.addTemplateTrigger.on(
      'click',
      function(_this) {
        return function(e) {
          var ajaxOptions;
          e.preventDefault();
          if (!_this.state) {
            return false;
          }
          ajaxOptions = { url: $(e.target).attr('href') };
          return $(document).trigger('load:dialog.nearme', [ ajaxOptions ]);
        };
      }(this)
    );
  };

  DimensionTemplates.prototype.prepareFields = function(attr) {
    var out;
    out = {};
    this.container.find('[data-' + attr + ']').each(function() {
      return out[$(this).data(attr)] = $(this);
    });
    return out;
  };

  DimensionTemplates.prototype.initialize = function() {
    var interval;
    if (!(this.dimensions_templates_select.length > 0)) {
      return;
    }
    return interval = window.setInterval(
      function(_this) {
        return function() {
          if (_this.dimensions_templates_select.get(0).selectize) {
            window.clearInterval(interval);
            _this.setDefaultOptionAsSelected();
            return _this.updateDimensionsFieldsFromTemplates();
          }
        };
      }(this),
      50
    );
  };

  DimensionTemplates.prototype.toggle = function(state) {
    this.state = state;
    this.container.toggleClass('form-section-disabled', !state);
    this.container.find('input, textarea').attr('readonly', !state);
    return this.container.find('select').each(function() {
      if (state) {
        return this.selectize.enable();
      } else {
        return this.selectize.disable();
      }
    });
  };

  DimensionTemplates.prototype.updateUnits = function() {
    var i, item, j, len, len1, new_element, new_elements, ref, results, unit_selectize, unit_type;
    unit_type = this.unit_of_measure.val();
    ref = [ 'weight', 'height', 'width', 'depth' ];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      unit_selectize = this.unit_fields[item].get(0).selectize;
      unit_selectize.clearOptions();
      new_elements = this.getOptionsTextByUnitType(unit_type, item);
      for (j = 0, len1 = new_elements.length; j < len1; j++) {
        new_element = new_elements[j];
        unit_selectize.addOption({ value: new_element, text: new_element });
      }
      results.push(unit_selectize.setValue(new_elements[0]));
    }
    return results;
  };

  DimensionTemplates.prototype.setDefaultOptionAsSelected = function() {
    var i, key, len, option, ref, results;
    if (
      this.container.parents('form').find('input[name="_method"]').val() === 'put' ||
        $('#product_errors_present').length > 0
    ) {
      return;
    }
    ref = Object.keys(this.dimensions_templates_select.get(0).selectize.options);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];
      option = this.dimensions_templates_select.get(0).selectize.options[key];
      if (option.template.use_as_default) {
        results.push(this.dimensions_templates_select.get(0).selectize.setValue(option.value));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  DimensionTemplates.prototype.updateDimensionsFieldsFromTemplates = function() {
    var current,
      data_options,
      i,
      item,
      len,
      new_element,
      new_elements,
      ref,
      results,
      unit_selectize;
    current = this.dimensions_templates_select.get(0).selectize.items[0];
    if (current) {
      data_options = this.dimensions_templates_select.get(0).selectize.options[current].template;
    }
    if (!data_options) {
      return this.updateDimensionTemplateSelect();
    }
    this.unit_of_measure.val(data_options['unit_of_measure']);
    ref = [ 'weight', 'height', 'width', 'depth' ];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      unit_selectize = this.unit_fields[item].get(0).selectize;
      unit_selectize.clearOptions();
      new_elements = this.getOptionsTextByUnitType(data_options['unit_of_measure'], item);
      this.dimension_fields[item].val(data_options[item]);
      results.push(
        function() {
          var j, len1, results1;
          results1 = [];
          for (j = 0, len1 = new_elements.length; j < len1; j++) {
            new_element = new_elements[j];
            unit_selectize.addOption({ value: new_element, text: new_element });
            if (data_options[item + '_unit'] === new_element) {
              results1.push(unit_selectize.setValue(new_element));
            } else {
              results1.push(void 0);
            }
          }
          return results1;
        }()
      );
    }
    return results;
  };

  DimensionTemplates.prototype.updateDimensionTemplateSelect = function() {
    var current;
    current = null;
    $.each(
      this.dimensions_templates_select.get(0).selectize.options,
      function(_this) {
        return function(index, option) {
          var i, item, len, ref, template;
          template = option.template;
          if (_this.unit_of_measure.val() !== template['unit_of_measure']) {
            return;
          }
          ref = [ 'weight', 'height', 'width', 'depth' ];
          for (i = 0, len = ref.length; i < len; i++) {
            item = ref[i];
            if (_this.dimension_fields[item].val() !== template[item]) {
              return;
            }
          }
          return current = index;
        };
      }(this)
    );
    if (current !== null) {
      return this.dimensions_templates_select.get(0).selectize.setValue(current);
    }
  };

  DimensionTemplates.prototype.getOptionsTextByUnitType = function(unit_type, unit_name) {
    var i, item, len, ref, result;
    result = [];
    if ($.inArray(unit_name, [ 'width', 'height', 'depth' ]) >= 0) {
      unit_name = 'length';
    }
    ref = this.units[unit_type][unit_name];
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      result.push(item);
    }
    return result;
  };

  return DimensionTemplates;
}();

module.exports = DimensionTemplates;
