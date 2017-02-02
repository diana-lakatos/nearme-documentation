require 'jstree/dist/jstree.min.js'

module.exports = class CategoryTreeInput

  constructor: (el) ->
    @container = $(el)
    @input = @container.find('[data-category-id]')
    @categoryId = @input.data('category-id')
    @apiUrl = @input.data('category-api-url')
    @isMultiple = !!@input.data('category-multiple-choice')
    @selectedCategories = (@input.data('value')+"").split(',')
    @attrName = "#{@input.attr('name')}[]"

    @input.remove()

    @build()
    @initialize()

  build: ->
    @treeContainer = $('<div class="tree-container"/>')
    @valueInputsContainer = $('<div class="value-inputs"/>')
    @container.append(@treeContainer, @valueInputsContainer)

  initialize: =>
    $.ajax
      url: @apiUrl
      data:
        category_ids: @selectedCategories,
      success: @initTree

  initTree: (data) =>
    conf =
      core:
        data: data.categories
        themes:
          name: 'default'
          icons: false

      plugins: ["checkbox"]

      checkbox:
        three_state: false,
        tie_selection: false

    @treeContainer.jstree(conf)

    @treeContainer.bind "loaded.jstree", (e, data) =>
      @update data.instance.get_checked()

    @treeContainer.on 'check_node.jstree', (e, data) =>
      data.instance.open_node(data.node)

      unless @isMultiple
        currentId = data.node.id
        parentIds = data.node.parents
        $.each data.instance.get_checked(true), (index, item) ->
          return if currentId == item.id or $.inArray(item.id, parentIds) > -1
          data.instance.uncheck_node(item.id)
          data.instance.uncheck_node(item.children_d)

      @update data.instance.get_checked()

    @treeContainer.on 'uncheck_node.jstree', (e, data) =>
      data.instance.close_all(data.node)
      data.instance.uncheck_node(data.node.children_d)
      @update data.instance.get_checked()

  update: (ids) ->
    ids = @treeContainer.jstree('get_checked')
    ids = _.uniq(ids)
    @valueInputsContainer.empty()
    if ids.length > 0
      $.each ids, (index, id) =>
        @valueInputsContainer.append("<input type='hidden' name='#{@attrName}' value='#{id}'>")
    else
      @valueInputsContainer.append("<input type='hidden' name='#{@attrName}' value=''>")
