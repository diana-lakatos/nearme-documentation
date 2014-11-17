class @InstanceAdmin.BuySellController

  constructor: (@container, @taxonomy_id) ->
    @bindEvents()
    @setupTaxonomiesTree()

  bindEvents: =>
    @container.find('input.zone_kind').on 'change', (e) =>
      @container.find('.zone-members-container').addClass('hide')
      @container.find("##{$(e.currentTarget).attr('id')}_container").removeClass('hide')

  setupTaxonomiesTree: =>
    if @container.find('#taxonomy_tree').length > 0
      $.ajax
        url: taxonomy_taxons_path.replace("/taxons", "/jstree").toString(),
        success: (taxonomy) ->
          last_rollback = null

          conf =
            json_data:
              data: taxonomy,
              ajax:
                url: (e) ->
                  (taxonomy_taxons_path + '/' + e.prop('id') + '/jstree').toString()
            themes:
              theme: "apple",
              url: jstree_theme_path
            strings:
              new_node: "New taxon",
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
                  if new_parent.prop("id") == "taxonomy_tree" && position == 0
                    return false

                  true
            contextmenu:
              items: (obj) ->
                InstanceAdmin.TaxonomiesTree.taxonTreeMenu(obj, this)
            plugins: ["themes", "json_data", "dnd", "crrm", "contextmenu"]

          $("#taxonomy_tree").jstree(conf)
            .bind("move_node.jstree", InstanceAdmin.TaxonomiesTree.handleMove)
            .bind("remove.jstree", InstanceAdmin.TaxonomiesTree.handleDelete)
            .bind("create.jstree", InstanceAdmin.TaxonomiesTree.handleCreate)
            .bind("rename.jstree", InstanceAdmin.TaxonomiesTree.handleRename)
            .bind "loaded.jstree", ->
              $(this).jstree("core").toggle_node($('.jstree-icon').first())

      $("#taxonomy_tree a").on "dblclick", (e) ->
        $("#taxonomy_tree").jstree("rename", this)

      # surpress form submit on enter/return
      $(document).keypress (e) ->
        if e.keyCode == 13
          e.preventDefault() 
