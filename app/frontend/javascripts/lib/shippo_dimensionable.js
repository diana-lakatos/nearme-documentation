var ShippoDimensionable;

ShippoDimensionable = {
  updateDimensionsFieldsFromTemplates: function() {
    return $(document).on(
      'change',
      '[data-js-element-identifier="product_form_templates_list"]',
      function(_this) {
        return function() {
          var data_options,
            i,
            item,
            j,
            len,
            len1,
            new_element,
            new_elements,
            ref,
            results,
            select_element,
            selected_template_option;
          selected_template_option = $(
            '[data-js-element-identifier="product_form_templates_list"]'
          ).find(':selected');
          if (typeof selected_template_option.attr('data-template') !== 'undefined') {
            data_options = jQuery.parseJSON(selected_template_option.attr('data-template'));
          } else {
            data_options = null;
          }
          if (data_options) {
            $(
              '[data-js-element-identifier="product_form_unit_of_measure"]'
            ).val(data_options['unit_of_measure']);
            ref = [ 'weight', 'height', 'width', 'depth' ];
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
              item = ref[i];
              select_element = $(
                '[data-js-element-identifier="product_form_input_' + item + '_unit"]'
              );
              select_element.empty();
              new_elements = _this.getOptionsTextByUnitType(data_options['unit_of_measure'], item);
              $(
                '[data-js-element-identifier="product_form_input_' + item + '"]'
              ).val(data_options[item]);
              for (j = 0, len1 = new_elements.length; j < len1; j++) {
                new_element = new_elements[j];
                if (data_options[item + '_unit'] === new_element) {
                  select_element.append(
                    $('<option selected></option>').attr('value', new_element).text(new_element)
                  );
                } else {
                  select_element.append(
                    $('<option></option>').attr('value', new_element).text(new_element)
                  );
                }
              }
              results.push(select_element.trigger('change'));
            }
            return results;
          }
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

module.exports = ShippoDimensionable;
