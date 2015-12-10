JavascriptModule = require('../../lib/javascript_module')
SearchableAdminResource = require('../searchable_admin_resource')

module.exports = class InstanceAdminSpamReportsController extends JavascriptModule
  @include SearchableAdminResource

  constructor: (@container) ->
    @commonBindEvents()
