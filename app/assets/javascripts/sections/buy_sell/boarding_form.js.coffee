class @BoardingForm
  constructor: (@form) ->
    @setupImages()

  processImage: (event, container) ->
    $(container).find('label').hide()
    $(container).append("<img src='" + event.fpfile.url + "'>")
    $(container).append('<label class="delete_image">Delete</label>')
    @setupImages()

  setupImages: ->
    @form.find(".delete_image").click ->
      $(this).parent().hide()

