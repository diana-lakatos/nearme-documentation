class @CategoriesController

  constructor: (@container) ->
    @setupCategoriesTree()

  setupCategoriesTree: =>
    if @container.find('#category_tree').length > 0
      that = this
      $.ajax
        url: categories_path
        data: {category_ids: selected_categories}
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

          $("#category_tree").jstree(conf)
            .bind "loaded.jstree", (e, data) ->
              if selected_categories.length > 0
                $.jstree._reference($('#category_tree')).open_all($('#category_tree').jstree('get_checked', null, true))
                for category_id, i in selected_categories
                  $("#category_tree").jstree('check_node', '#' + category_id); 
                  $("#category_tree").jstree('open_node', '#' + category_id); 

            .bind "check_node.jstree uncheck_node.jstree ", -> 
              that.setChecboxesValues()

            .bind 'check_node.jstree', (e, data) ->
              if single_choice_category && data.rslt.obj.attr('root') == 'true'    
                currentNode = data.rslt.obj.attr('id')
                $('#category_tree').jstree('get_checked', null, true).each ->
                  if currentNode != @id && $(@).attr("root") == 'true'
                    $.jstree._reference($('#category_tree')).uncheck_node '#' + @id
                  return
                return

            .bind 'check_node.jstree', (e, data) ->
              data.inst.open_all(data.rslt.obj, true)
              # data.inst.uncheck_all()
              # data.inst.check_node()

            .bind 'uncheck_node.jstree', (e, data) ->
              data.inst.close_all(data.rslt.obj, true);
              data.rslt.obj.find('li.jstree-checked').removeClass('jstree-checked').addClass('jstree-unchecked')

              # data.inst.uncheck_all()

      $("#category_tree a").on "dblclick", (e) ->
        $("#category_tree").jstree("rename", this)

      # surpress form submit on enter/return
      $(document).keypress (e) ->
        if e.keyCode == 13
          e.preventDefault() 

  handleAjaxError: (XMLHttpRequest, textStatus, errorThrown) ->
    $.jstree.rollback(last_rollback)
    $("#ajax_error").show().html("<strong>The server returned an error</strong><br />The requested change has not been accepted and the tree has been returned to its previous state, please try again")

  setChecboxesValues: ->
    categories_inputs = []
    category_tree_inputs = @container.find("#category_tree_inputs")
    category_tree_inputs.html('')
    $('#category_tree').jstree('get_checked', null, true).each ->
      $('<input name="'+ category_input_name + '">').attr('type','hidden').val(@id).appendTo(category_tree_inputs);
      return
    return