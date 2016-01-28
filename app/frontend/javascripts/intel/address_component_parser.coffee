module.exports = class AddressComponentParser

  constructor: (@inputWrapper) ->
    @input_name_prefix = @inputWrapper.find('input[data-address-components-input]').attr('name')
    @addressComponentWrapper = @inputWrapper.find('.address-component-wrapper')

  buildAddressComponentsInputs: (place) =>
    @clearAddressComponentInputs()
    @index = 0
    for addressComponent in place.result.address_components
      @buildInput("#{@input_name_prefix}[#{@index}][long_name]", addressComponent.long_name)
      @buildInput("#{@input_name_prefix}[#{@index}][short_name]", addressComponent.short_name)
      @buildInput("#{@input_name_prefix}[#{@index}][types]", addressComponent.types.toString())
      @index += 1

  buildInput: (name, value) =>
    input = $('<input type="hidden"/>')
    input.attr('name', name).addClass('address_components_input').val(value)
    @addressComponentWrapper.append(input)

  clearAddressComponentInputs: =>
    @inputWrapper.find('.address_components_input').each ->
      $(this).remove()
