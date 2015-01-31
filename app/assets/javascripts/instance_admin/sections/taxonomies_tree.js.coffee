class @InstanceAdmin.TaxonomiesTree
  handleAjaxError: (XMLHttpRequest, textStatus, errorThrown) ->
    $.jstree.rollback(last_rollback)
    $("#ajax_error").show().html("<strong>The server returned an error</strong><br />The requested change has not been accepted and the tree has been returned to its previous state, please try again")

  @handleMove: (e, data) ->
    last_rollback = data.rlbk
    position = data.rslt.cp
    node = data.rslt.o
    new_parent = data.rslt.np

    url = taxonomy_taxons_path + '/' + node.prop("id")
    $.ajax
      type: "POST",
      dataType: "json",
      url: url.toString(),
      data: ({_method: "put", "taxon[parent_id]": new_parent.prop("id"), "taxon[child_index]": position }),
      error: InstanceAdmin.TaxonomiesTree.handleAjaxError

    true


  @handleCreate: (e, data) ->
    last_rollback = data.rlbk
    node = data.rslt.obj
    name = data.rslt.name
    position = data.rslt.position
    new_parent = data.rslt.parent

    $.ajax
      type: "POST",
      dataType: "json",
      url: taxonomy_taxons_path,
      data: ({"taxon[name]": name, "taxon[parent_id]": new_parent.prop("id"), "taxon[child_index]": position }),
      error: InstanceAdmin.TaxonomiesTree.handleAjaxError,
      success: (data,result) ->
        node.prop('id', data.id)


  @handleRename: (e, data) ->
    last_rollback = data.rlbk
    node = data.rslt.obj
    name = data.rslt.new_name

    url = taxonomy_taxons_path + '/' + node.prop("id")

    $.ajax
      type: "POST",
      dataType: "json",
      url: url.toString(),
      data: {_method: "put", "taxon[name]": name },
      error: InstanceAdmin.TaxonomiesTree.handleAjaxError


  @handleDelete: (e, data) ->
    last_rollback = data.rlbk
    node = data.rslt.obj
    delete_url = taxonomy_taxons_path + '/' + node.prop("id")
    if confirm('Are you sure ?')
      $.ajax
        type: "POST",
        dataType: "json",
        url: delete_url.toString(),
        data: {_method: "delete"},
        error: InstanceAdmin.TaxonomiesTree.handleAjaxError
    else
      $.jstree.rollback(last_rollback)
      last_rollback = null


  @taxonTreeMenu: (obj, context) ->
    edit_url = taxonomy_taxons_path + '/' + obj.prop("id") + '/edit'
    create:
      label: "<i class='fa fa-plus'></i> Add",
      action: (obj) -> context.create(obj)
    rename:
      label: "<i class='fa fa-pencil'></i> Rename",
      action: (obj) -> context.rename(obj)
    remove:
      label: "<i class='fa fa-trash-o'></i> Remove",
      action: (obj) -> context.remove(obj)
    edit:
      separator_before: true,
      label: "<i class='fa fa-edit'></i> Edit",
      action: (obj) -> window.location = edit_url
