module.exports = class InstanceAdminRootCategoriesController

  constructor: (@container) ->
    @setupSortable()

  setupSortable: =>
    @container.sortable
      update: (event, ui) ->
        data = $(this).sortable('serialize')
    
        $.ajax
          data: data
          type: 'PUT'
          url: '/instance_admin/manage/categories_positions'

