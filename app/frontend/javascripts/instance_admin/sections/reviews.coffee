JavascriptModule = require('../../lib/javascript_module')
SearchableAdminResource = require('../searchable_admin_resource')

require('../../../vendor/jquery-ui-datepicker')

module.exports = class InstanceAdminReviewsController extends JavascriptModule
  @include SearchableAdminResource

  constructor: (@container) ->
    @commonBindEvents()
    @bindEvents()

  bindEvents: ->
    @container.find('#to, #from').datepicker()

    @container.on 'click', '#to, #from', (e) ->
      e.stopPropagation()

    @container.on 'click', '.more-filters', =>
      @container.find('.filters-expanded').slideToggle()
      @container.find('.more-filters').toggleClass('active')
      @container.find('.more-filters .fa').toggleClass('fa-angle-right fa-angle-down')

    @container.find('.filters-expanded').on 'click', '.close-link', =>
      @container.find('.filters-expanded').slideUp()
      @container.find('.more-filters').removeClass('active')
      @container.find('.more-filters .fa').toggleClass('fa-angle-down fa-angle-right')

