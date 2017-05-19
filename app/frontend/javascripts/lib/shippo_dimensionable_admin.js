var ShippoDimensionableAdmin;

ShippoDimensionableAdmin = {
  updateUnitsOfMeasure: function() {
    return $('[data-js-element-identifier=admin_dimensions_template_select]').change(
      function(_this) {
        return function() {
          var form_unit,
            form_unit_element,
            i,
            item,
            len,
            new_element,
            new_elements,
            ref,
            results,
            select_element;
          form_unit_element = $('[data-js-element-identifier=admin_dimensions_template_select]');
          form_unit = 'imperial';
          if (form_unit_element.length === 1) {
            form_unit = $(form_unit_element[0]).val();
          }
          ref = [ 'weight', 'height', 'width', 'depth' ];
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            item = ref[i];
            select_element = $(
              '[data-js-element-identifier=admin_dimensions_template_form_' + item + ']'
            );
            select_element.empty();
            new_elements = _this.getOptionsTextByUnitType(form_unit, item);
            results.push(
              function() {
                var j, len1, results1;
                results1 = [];
                for (j = 0, len1 = new_elements.length; j < len1; j++) {
                  new_element = new_elements[j];
                  results1.push(
                    select_element.append(
                      $('<option></option>').attr('value', new_element).text(new_element)
                    )
                  );
                }
                return results1;
              }()
            );
          }
          return results;
        };
      }(this)
    );
  },
  getOptionsTextByUnitType: function(unit_type, unit_name) {
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
  }
};

module.exports = ShippoDimensionableAdmin;
