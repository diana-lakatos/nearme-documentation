class @Photo.Initializer
  
  @initialize: (scope = $('body')) ->
    $('.fileupload', scope).each (index, element) =>
      new Photo.Uploader($(element))
