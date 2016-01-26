JavascriptModule = require('../../lib/javascript_module')
SearchableAdminResource = require('../searchable_admin_resource')
SearchableAdminService = require('../searchable_admin_service')

module.exports = class InstanceAdminProductsController extends JavascriptModule
  @include SearchableAdminResource
  @include SearchableAdminService

  constructor: (@container) ->
    @commonBindEvents()
    @serviceBindEvents()

