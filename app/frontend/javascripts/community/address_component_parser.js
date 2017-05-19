var AddressComponentParser,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

AddressComponentParser = function() {
  function AddressComponentParser(inputWrapper) {
    this.inputWrapper = inputWrapper;
    this.clearAddressComponentInputs = bind(this.clearAddressComponentInputs, this);
    this.buildInput = bind(this.buildInput, this);
    this.buildAddressComponentsInputs = bind(this.buildAddressComponentsInputs, this);
    this.input_name_prefix = this.inputWrapper
      .find('input[data-address-components-input]')
      .attr('name');
    this.addressComponentWrapper = this.inputWrapper.find('.address-component-wrapper');
  }

  AddressComponentParser.prototype.buildAddressComponentsInputs = function(place) {
    var addressComponent, i, len, ref, results;
    this.clearAddressComponentInputs();
    this.index = 0;
    ref = place.result.address_components;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      addressComponent = ref[i];
      this.buildInput(
        this.input_name_prefix + '[' + this.index + '][long_name]',
        addressComponent.long_name
      );
      this.buildInput(
        this.input_name_prefix + '[' + this.index + '][short_name]',
        addressComponent.short_name
      );
      this.buildInput(
        this.input_name_prefix + '[' + this.index + '][types]',
        addressComponent.types.toString()
      );
      results.push(this.index += 1);
    }
    return results;
  };

  AddressComponentParser.prototype.buildInput = function(name, value) {
    var input;
    input = $('<input type="hidden"/>');
    input.attr('name', name).addClass('address_components_input').val(value);
    return this.addressComponentWrapper.append(input);
  };

  AddressComponentParser.prototype.clearAddressComponentInputs = function() {
    return this.inputWrapper.find('.address_components_input').each(function() {
      return $(this).remove();
    });
  };

  return AddressComponentParser;
}();

module.exports = AddressComponentParser;
