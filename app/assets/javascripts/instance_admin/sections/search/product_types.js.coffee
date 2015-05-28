class @InstanceAdmin.SearchProductTypesController

  constructor: (@container) ->
    @bindEvents()

  bindEvents: =>
    @container.find('.service .header').click (event) =>
      clicker = $(event.target)
      index = $('.header').index(clicker.parent('.header'))
      content = $($('.search-system').get(index))
      input = null
      if clicker.prop('checked') != undefined
        input = clicker
        content.addClass('hidden')
        input.prop('checked', input.prop('checked'))
      else
        input = clicker.find('input')
        input.prop('checked', !input.prop('checked'))

      if input.prop('checked')
        content.removeClass('hidden')
      else
        content.addClass('hidden')
        
      @updateSearchable(input)

    @container.find('td.custom_attribute input').click (event) =>
      clicker = $(event.target)
      @updateSearchableAttribute(clicker)

    @container.find('.product_type_custom_attributes').click (event) ->
      event.preventDefault()
      clicker = $(event.target)
      $(clicker.attr('data-product-type-custom-attributes')).toggleClass('hidden')

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
      data: { product_type: {searchable: checkbox.prop('checked')}}
      success: (res) =>
        spinner.addClass('hidden')
        checkbox.removeClass('hidden')