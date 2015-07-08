class @InstanceAdmin.SearchTransactableTypeController

  constructor: (@container) ->
    @bindEvents()

  bindEvents: =>
    @container.find('.service .header input').each (i, element) =>
      @toogle_custom_attributes($(element))

     @container.find('.service .header').click (event) =>
      clicker = $(event.target)
      input = @toogle_custom_attributes(clicker)
      @updateSearchable(input)

    @container.find('td.custom_attribute input').click (event) =>
      clicker = $(event.target)
      @updateSearchableAttribute(clicker)

    @container.find(@transactable_type_class_name() + '_custom_attributes').click (event) ->
      event.preventDefault()
      clicker = $(event.target)
      $(clicker.attr(@data_selector_name())).toggleClass('hidden')

  toogle_custom_attributes: (clicker) =>
    index = $('.header').index(clicker.parent('.header'))
    content = $($('.search-system').get(index))
    input = null
    if clicker.prop('checked') != undefined
      input = clicker
      content.addClass('hidden')
      input.prop('checked', input.prop('checked'))
    else
      input = clicker.parent().find('input')
      input.prop('checked', !input.prop('checked'))

    if input.prop('checked')
      content.removeClass('hidden')
    else
      content.addClass('hidden')

    return input

  updateSearchableAttribute: (clicker) =>
    checkbox = clicker
    spinner = @container.find(checkbox.attr('spinner'))

    checkbox.addClass('hidden')
    spinner.removeClass('hidden')

    $.ajax
      type: 'PUT'
      url: checkbox.attr('data-url')
      dataType: 'JSON'
      data: { custom_attribute: {searchable: checkbox.prop('checked')}}
      success: (res) =>
        spinner.addClass('hidden')
        checkbox.removeClass('hidden')


  updateSearchable: (clicker) =>
    checkbox = clicker
    spinner = @container.find(checkbox.attr('spinner'))

    checkbox.addClass('hidden')
    spinner.removeClass('hidden')

    $.ajax
      type: 'PUT'
      url: checkbox.attr('data-url')
      dataType: 'JSON'
      data: @transactable_data(checkbox)
      success: (res) =>
        spinner.addClass('hidden')
        checkbox.removeClass('hidden')