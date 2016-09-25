module.exports = class InstanceAdminCustomAttributesController

  constructor: (@container) ->
    @htmlTag = @container.find('#custom_attribute_html_tag')

    @bindEvents()

  bindEvents: ->
    @htmlTag.on 'change', ->
      $('.properties').removeClass('active')

      section = switch this.value
        when 'range' then '.range-properties'

      $(section).addClass('active')
