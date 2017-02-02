require('select2/select2')
require('../../vendor/jquery.jstree')

module.exports = class CategoriesController

  constructor: (@container) ->
    @setupCategoriesTrees()
    @autocomplete()
    @last_rollback = null

  setupCategoriesTrees: =>
    if @container.find('.tree_container').length > 0
      for tree_container, i in @container.find('.tree_container')
        @setupCategoriesTreeFor( $(tree_container) )

  setupCategoriesTreeFor: (tree_container) =>
    that = this
    category_id = tree_container.attr('data-category-id')
    category_tree = tree_container.find('.category_tree')
    if category_tree.length > 0
      selected_category_ids = tree_container.find('.category_ids:not([data-value=""])').eq(0).attr('data-value')
      selected_categories = if selected_category_ids == undefined then [] else selected_category_ids.split(',')
      $.ajax
        url: "/dashboard/api/categories/#{category_id}/tree"
        data:
          category_ids: selected_categories,
          category_id: category_id
        success: (category) ->
          that.last_rollback = null

          conf =
            json_data:
              data: category,
              ajax:
                url: (e) ->
                  "/dashboard/api/categories/#{e.prop('id')}/tree"
                data: {category_ids: selected_categories}

            themes:
              theme: "apple",
              url: false
            strings:
              new_node: "New category",
              loading: "Loading ..."
            plugins: ["themes", "json_data", "checkbox", 'real_checkboxes']
            checkbox:
              real_checkboxes: false,
              three_state: false,
              tie_selection: false,
              cascade: 'up',
              two_state: true

          category_tree.jstree(conf)
            .bind "loaded.jstree", (e, data) ->
              that.bindClickEvent(category_tree)
              selected_categories = conf.json_data.ajax.data.category_ids
              if selected_categories.length > 0
                $.jstree._reference(category_tree).open_all(category_tree.jstree('get_checked', null, true))
                for category_id, i in selected_categories
                  category_tree.jstree('check_node', $('#' + category_id))
                  category_tree.jstree('open_node', $('#' + category_id))

            .bind "check_node.jstree uncheck_node.jstree ", ->
              that.setChecboxesValues(tree_container)

            .bind 'check_node.jstree', (e, data) ->
              if (tree_container.find(".single_choice_category").val() == "false") && data.rslt.obj.attr('root') == 'true'
                currentNode = data.rslt.obj.attr('id')
                category_tree.jstree('get_checked', null, true).each ->
                  if currentNode != @id && $(@).attr("root") == 'true'
                    $.jstree._reference(category_tree).uncheck_node '#' + @id
                  return
                return
            .bind 'after_open.jstree', (e, data) ->
              that.bindClickEvent(category_tree)
              that.setChecboxesValues(tree_container)
            .bind 'after_close.jstree', (e, data) ->
              that.setChecboxesValues(tree_container)

            .bind 'check_node.jstree', (e, data) ->
              data.inst.open_node(data.rslt.obj, true)

            .bind 'uncheck_node.jstree', (e, data) ->
              data.inst.close_all(data.rslt.obj, true)
              data.rslt.obj.find('li.jstree-checked').removeClass('jstree-checked').addClass('jstree-unchecked')

  bindClickEvent: (category_tree) ->
    category_tree.find("a").unbind "click"
    category_tree.find("a").on "click", (e) ->
      e.preventDefault()
      e.stopPropagation()
      if category_tree.jstree("is_checked", this)
        category_tree.jstree("uncheck_node", this)
      else
        category_tree.jstree("check_node", this)

  handleAjaxError: (XMLHttpRequest, textStatus, errorThrown) =>
    $.jstree.rollback(@last_rollback)
    $("#ajax_error").show().html("<strong>The server returned an error</strong><br />The requested change has not been accepted and the tree has been returned to its previous state, please try again")
    window.Raygun.send(errorThrown, textStatus) if window.Raygun

  setChecboxesValues: (tree_container) ->
    category_tree = tree_container.find('.category_tree')
    categories_inputs = []
    category_tree_inputs = tree_container.find(".category_tree_inputs")
    category_tree_inputs.html('')
    category_tree.jstree('get_checked', null, true).each ->
      $('<input name="'+ tree_container.find('.category_ids').attr('name') + '">').attr('type','hidden').val(@id).appendTo(category_tree_inputs)
      return
    return

  autocomplete: ->
    if @container.find("input[data-category-autocomplete]").length > 0
      $.each @container.find("input[data-category-autocomplete]"), (index, select) ->

        $(select).select2
          placeholder: "Enter a category"
          multiple: true
          initSelection: (element, callback) ->
            url = "/dashboard/api/categories/#{$(select).attr('data-category-id')}"
            $.getJSON url, { init_selection: 'true', ids: $(select).attr("data-selected-categories") }, (data) ->
              callback data

          ajax:
            url: "/dashboard/api/categories/#{$(select).attr('data-category-id')}"
            datatype: "json"
            data: (term, page) ->
              per_page: 50
              page: page
              q:
                name_cont: term

            results: (data, page) ->
              results: data

          formatResult: (category) ->
            category.pretty_name

          formatSelection: (category) ->
            category.pretty_name

        # select2 will not call initSelection if the input has an empty value
        # (which is always the case with :array_input the way we built it)
        # This is a workaround to trigger the initial value readout
        $(select).select2('val', [])

