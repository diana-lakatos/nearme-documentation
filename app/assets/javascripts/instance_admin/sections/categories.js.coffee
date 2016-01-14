class @InstanceAdmin.CategoriesController

  constructor: (@container, @category_id) ->
    @setupCategoriesTree()

  setupCategoriesTree: =>
    if @container.find('#category_tree').length > 0
      that = this
      $.ajax
        url: (categories_path + '/' + @category_id + '/jstree?root=true').toString()
        success: (category) ->
          last_rollback = null

          conf =
            json_data:
              data: category,
              ajax:
                url: (e) ->
                  (categories_path + '/' + e.prop('id') + '/jstree').toString()
            themes:
              theme: "apple",
              url: false
            strings:
              new_node: "New category",
              loading: "Loading ..."
            crrm:
              move:
                check_move: (m) ->
                  position = m.cp
                  node = m.o
                  new_parent = m.np

                  # no parent or cant drag and drop
                  if !new_parent || node.prop("rel") == "root"
                    return false

                  # can't drop before root
                  if new_parent.prop("id") == "category_tree"
                    return false

                  true
            contextmenu:
              items: (obj) ->
                that.categoryTreeMenu(obj, this)
            plugins: ["themes", "json_data", "dnd", "crrm", "contextmenu"]

          $("#category_tree").jstree(conf)
            .bind("move_node.jstree", that.handleMove)
            .bind("remove.jstree", that.handleDelete)
            .bind("create.jstree", that.handleCreate)
            .bind("rename.jstree", that.handleRename)
            .bind "loaded.jstree", ->
              $(this).jstree("core").toggle_node($('.jstree-icon').first())

      $("#category_tree a").on "dblclick", (e) ->
        $("#category_tree").jstree("rename", this)

      # surpress form submit on enter/return
      $(document).keypress (e) ->
        if e.keyCode == 13
          e.preventDefault()


  handleAjaxError: (XMLHttpRequest, textStatus, errorThrown) ->
    $.jstree.rollback(last_rollback)
    $("#ajax_error").show().html("<strong>The server returned an error</strong><br />The requested change has not been accepted and the tree has been returned to its previous state, please try again")

  handleMove: (e, data) ->
    last_rollback = data.rlbk
    position = data.rslt.cp
    node = data.rslt.o
    new_parent = data.rslt.np

    url = categories_path + '/' + node.prop("id")
    $.ajax
      type: "POST",
      dataType: "json",
      url: url.toString(),
      data: ({_method: "put", "category[parent_id]": new_parent.prop("id"), "category[child_index]": position }),
      error: @handleAjaxError

    true


  handleCreate: (e, data) ->
    last_rollback = data.rlbk
    node = data.rslt.obj
    name = data.rslt.name
    position = data.rslt.position
    new_parent = data.rslt.parent

    $.ajax
      type: "POST",
      dataType: "json",
      url: categories_path,
      data: ({"category[name]": name, "category[parent_id]": new_parent.prop("id"), "category[child_index]": position }),
      error: @handleAjaxError,
      success: (data,result) ->
        node.prop('id', data.id)


  handleRename: (e, data) ->
    last_rollback = data.rlbk
    node = data.rslt.obj
    name = data.rslt.new_name

    url = categories_path + '/' + node.prop("id")

    $.ajax
      type: "POST",
      dataType: "json",
      url: url.toString(),
      data: {_method: "put", "category[name]": name },
      success: (data,result) ->
        if data["message"].length > 0
          alert(data["message"])
      error: @handleAjaxError


  handleDelete: (e, data) ->
    last_rollback = data.rlbk
    node = data.rslt.obj
    delete_url = categories_path + '/' + node.prop("id")
    if confirm('Are you sure ?')
      $.ajax
        type: "POST",
        dataType: "json",
        url: delete_url.toString(),
        data: {_method: "delete"},
        error: @handleAjaxError
    else
      $.jstree.rollback(last_rollback)
      last_rollback = null


  categoryTreeMenu: (obj, context) ->
    edit_url = categories_path + '/' + obj.prop("id") + '/edit'
    actions =
      create:
        label: "<i class='fa fa-plus'></i> Add",
        action: (obj) -> context.create(obj)
    if obj.attr('is_root') != 'true'
      actions.rename =
        label: "<i class='fa fa-pencil'></i> Rename",
        action: (obj) -> context.rename(obj)
      actions.remove =
        label: "<i class='fa fa-trash-o'></i> Remove",
        action: (obj) -> context.remove(obj)
    actions
