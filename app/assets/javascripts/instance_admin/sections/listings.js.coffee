class @InstanceAdmin.ListingsController extends @JavascriptModule
  @include SearchableAdminResource
  @include SearchableAdminService

  constructor: (@container) ->
    @commonBindEvents()
    @serviceBindEvents()

