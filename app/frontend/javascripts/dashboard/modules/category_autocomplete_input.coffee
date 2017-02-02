require 'selectize/dist/js/selectize'

module.exports = class CategoryAutocompleteInput

  constructor: (el) ->
    @input = $(el)
    @categoryId = @input.data('category-id')
    @attrName = "#{@input.attr('name')}[]"
    @input.removeAttr('name')

    @build()
    @initialize()
    @update()

  build: ->
    @valueInputsContainer = $('<div class="value-inputs"/>')
    @input.after(@valueInputsContainer)


  initialize: ->

    @input.selectize
      create: false,
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
      options: @input.data('items'),
      load: (query, callback) =>
        return callback() unless query.length

        $.ajax
          url: @input.data('api'),
          type: 'GET',
          dataType: 'json',
          data:
            q:
              name_cont: query
          error: ->
            callback()

          success: (res) ->
            callback(res)
      onChange: @update

  update: =>
    ids = @input.get(0).selectize.getValue().split(',')
    @valueInputsContainer.empty()

    $.each ids, (index, id) =>
      @valueInputsContainer.append("<input type='hidden' name='#{@attrName}' value='#{id}'>")
