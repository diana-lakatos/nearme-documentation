class @CategoriesController

  constructor: (@container) ->
    @setupCategoriesTrees()
    @autocomplete()

  setupCategoriesTrees: =>
    if @container.find('.category_tree').length > 0
      for category_id, i in display_categories
        @setupCategoriesTreeFor(category_id)

  setupCategoriesTreeFor: (category_id) =>
    that = this
    tree_content = @container.find("#category_" + category_id + "_tree_content")
    tree_container = tree_content.find('.category_tree')
    if tree_container.length > 0
      $.ajax
        url: (categories_path + '/' + category_id).toString()
        data:
          category_ids: selected_categories,
          category_id: category_id
        success: (category) ->
          last_rollback = null

          conf =
            json_data:
              data: category,
              ajax:
                url: (e) ->
                  (categories_path + '/' + e.prop('id')).toString()
                data: {category_ids: selected_categories}

            themes:
              theme: "apple",
              url: jstree_theme_path
            strings:
              new_node: "New category",
              loading: "Loading ..."
            plugins: ["themes", "json_data", "dnd", "checkbox", 'real_checkboxes']
            checkbox:
              real_checkboxes: false,
              three_state: false,
              tie_selection: false,
              cascade: 'up',
              two_state: true

          tree_container.jstree(conf)
            .bind "loaded.jstree", (e, data) ->
              that.bindClickEvent(tree_container)
              if selected_categories.length > 0
                $.jstree._reference(tree_container).open_all(tree_container.jstree('get_checked', null, true))
                for category_id, i in selected_categories
                  tree_container.jstree('check_node', '#' + category_id);
                  tree_container.jstree('open_node', '#' + category_id);

            .bind "check_node.jstree uncheck_node.jstree ", ->
              that.setChecboxesValues(tree_content)

            .bind 'check_node.jstree', (e, data) ->
              if (tree_content.find(".single_choice_category").val() == "false") && data.rslt.obj.attr('root') == 'true'
                currentNode = data.rslt.obj.attr('id')
                tree_container.jstree('get_checked', null, true).each ->
                  if currentNode != @id && $(@).attr("root") == 'true'
                    $.jstree._reference(tree_container).uncheck_node '#' + @id
                  return
                return
            .bind 'after_open.jstree', (e, data) ->
              that.bindClickEvent(tree_container)
            .bind 'check_node.jstree', (e, data) ->
              data.inst.open_all(data.rslt.obj, true)

            .bind 'uncheck_node.jstree', (e, data) ->
              data.inst.close_all(data.rslt.obj, true);
              data.rslt.obj.find('li.jstree-checked').removeClass('jstree-checked').addClass('jstree-unchecked')

  bindClickEvent: (tree_container) ->
    tree_container.find("a").unbind "click"
    tree_container.find("a").on "click", (e) ->
      e.preventDefault();
      e.stopPropagation();
      if tree_container.jstree("is_checked", this)
        tree_container.jstree("uncheck_node", this)
      else
        tree_container.jstree("check_node", this)

  handleAjaxError: (XMLHttpRequest, textStatus, errorThrown) ->
    $.jstree.rollback(last_rollback)
    $("#ajax_error").show().html("<strong>The server returned an error</strong><br />The requested change has not been accepted and the tree has been returned to its previous state, please try again")

  setChecboxesValues: (tree_content) ->
    tree_container = tree_content.find('.category_tree')
    categories_inputs = []
    category_tree_inputs = tree_content.find(".category_tree_inputs")
    category_tree_inputs.html('')
    tree_container.jstree('get_checked', null, true).each ->
      $('<input name="'+ category_input_name + '">').attr('type','hidden').val(@id).appendTo(category_tree_inputs);
      return
    return

  autocomplete: () ->
    if @container.find("input[data-category-autocomplete]").length > 0
      $.each @container.find("input[data-category-autocomplete]"), (index, select) ->
        $(select).select2
          placeholder: "Enter a category"
          multiple: true
          initSelection: (element, callback) ->
            url = autocomplete_categories_path + '/' + $(select).attr('data-category-id')
            $.getJSON url, { init_selection: 'true', ids: $(select).attr("data-selected-catgories") }, (data) ->
              callback data

          ajax:
            url: autocomplete_categories_path + '/' + $(select).attr('data-category-id')
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




