SetupNestedForm = require('../setup_nested_form')

module.exports = class BoardingForm
  constructor: (@form) ->
    @setupImages()
    @setupDocumentRequirements()

  processImage: (event, container) ->
    $(container).find('label').hide()
    $(container).append("<img src='" + event.fpfile.url + "'>")
    $(container).append('<label class="delete_image">Delete</label>')
    @setupImages()

  setupImages: ->
    @form.find(".delete_image").click ->
      $(this).parent().hide()

  setupDocumentRequirements: ->
    nestedForm = new SetupNestedForm(@form)
    nestedForm.setup(".remove-document-requirement:not(:first)",
                ".document-hidden", ".remove-document",
                ".document-requirement",
                ".document-requirements .add-new", true)

