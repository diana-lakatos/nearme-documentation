class Home.Controller

  constructor: (@container) ->
    @callToAction = @container.find('a[data-call-to-action]') 
    @howItWorks = @container.find('section.how-it-works')
    @homepageContentTopOffset = 20
    @form = $("form#listing_search")
    @queryField = @form.find('input#search')
    @prodQueryField = @form.find('input#search_prod')
    @transactableTypeRadio = @form.find("input[name='transactable_type_id']")
    @transactableTypeSelect = @form.find("select[name='transactable_type_id']")
    @isBuyableField = @form.find("input#is_buyable")
    @crosshairs = @form.find("div.geolocation")
    @bindEvents()


  bindEvents: =>
    @callToAction.on 'click', (e) =>
      content_top = @howItWorks.offset().top - @homepageContentTopOffset
      $('html, body').animate
        scrollTop: content_top
        900
      false

    @form.on 'submit', (event) =>
      if @prodQueryField.length > 0 && @isBuyableField.val() isnt "true"
        @prodQueryField.val('')
      true

    if @transactableTypeRadio.length > 0
      @toggleGeocoding(@transactableTypeRadio)
      @transactableTypeRadio.bind "change", (event) =>
        @toggleGeocoding($(event.target))
    else if @transactableTypeSelect.length > 0
      @toggleGeocoding(@transactableTypeSelect)
      @transactableTypeSelect.bind "change", (event) =>
        @toggleGeocoding($(event.target))

  toggleGeocoding: (field) ->
    if @transactableTypeRadio.length > 0
      field ||= @form.find("input[name='transactable_type_id']:checked")
    else
      field = field.find("option:selected")

    is_buyable = field.data('buyable')
    @isBuyableField.val(is_buyable)

    if @prodQueryField.length > 0
      if is_buyable
        @queryField.hide()
        @crosshairs.hide()
        @prodQueryField.show()
      else
        @queryField.show()
        @crosshairs.show()
        @prodQueryField.hide()
