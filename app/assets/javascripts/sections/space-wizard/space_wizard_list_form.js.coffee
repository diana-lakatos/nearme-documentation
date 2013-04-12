class @SpaceWizardSpaceForm

  constructor: (@container) ->
    @setupMap()

    @address = new AddressField(@container.find('[data-behavior=address-autocomplete]'))
    @address.onLocate (lat, lng) =>
      latlng = new google.maps.LatLng(lat, lng)

      @map.marker.setPosition(latlng)
      @mapContainer.show()
      google.maps.event.trigger(@map.map, 'resize')
      @map.map.setCenter(latlng)

    @container.find('.control-group').addClass('input-disabled').find(':input').attr("disabled", true)
    @input_number = 0
    @input_length = @container.find('.control-group').length

    @priceInputs = @container.find('input[name*=price]')
    @freeCheckbox = @container.find('input[type=checkbox][name*=free]')
    @bindEvents()
    @unlockInput()

  unlockInput: ->
    if @input_number < @input_length
      @container.find('.control-group').eq(@input_number).removeClass('input-disabled').find(':input').removeAttr("disabled").eq(0).focus()
      # hack to ignore chosen - just unlock the next field after chosen
      if @container.find('.control-group').eq(@input_number).find('.custom-select').length > 0
        @input_number = @input_number + 1
        @unlockInput()

  setupMap: ->
    @mapContainer = @container.find('.map')

    @map = { map: null, markers: [] }
    @map.map = SmartGoogleMap.createMap(@mapContainer.find('.map-container')[0], {
      zoom: 16,
      mapTypeControl: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

    @map.marker = new google.maps.Marker({
      map: @map.map,
      icon: @mapContainer.attr("data-marker"),
      draggable: true
    })

    # When the marker is dragged, update the lat/lng form position
    google.maps.event.addListener @map.marker, 'drag', =>
      position = @map.marker.getPosition()
      @address.setLatLng(position.lat(), position.lng())

  bindEvents: =>
    @container.on 'keyup change blur', 'input[name*=daily_price], input[name*=weekly_price], input[name*=monthly_price]', (event) =>
      @priceChanged(event)

    @container.on 'change', 'input[type=checkbox][name*=free]', =>
      @freeChanged()

    @container.on 'change', '#user_companies_attributes_0_locations_attributes_0_currency', (event) ->
      $('.currency-holder').html($('#currency_'+ $(this).val()).text())
    $('#company_locations_attributes_0_currency').trigger('change')

    # Progress to the next form field when a selection is made from select elements
    @container.on 'change', 'select', (event) =>
      $(event.target).closest('.control-group').next().removeClass('input-disabled').find(':input').removeAttr('disabled').focus()

    ClientSideValidations.callbacks.element.pass = (element, callback, eventData) =>
      callback()
      index = element.closest('.control-group').index()
      if @allValid()
        if index > @input_number
          @input_number = index
        else
          @input_number = @input_number + 1
        @unlockInput()

    ClientSideValidations.callbacks.element.fail = (element, message, callback, eventData) =>
      callback()
      element.focus()
      element.parent().effect('shake', { easing: 'linear' })

    ClientSideValidations.callbacks.form.fail = (form, eventData) ->
      form.closest('.error-block').parent().ScrollTo()

    ClientSideValidations.callbacks.form.before = (form, eventData) =>
      if @container.find('.control-group :input:disabled').length > 0
        if @container.find('.control-group').eq(@input_number).find(':input').eq(0).val() != ''
          @container.find('.control-group').eq(@input_number+1).removeClass('input-disabled').find(':input').removeAttr('disabled')

  freeChanged: ->
    if @freeCheckbox.prop('checked')
      @priceInputs.val('')
    else
      @priceInputs.eq(0).focus().val('')

  allValid: ->
    @container.find('.error-block').length == 0

  priceChanged: (event) ->
    prices = (parseFloat(priceInput.value) for priceInput in @priceInputs)
    (if price > 0 then checkFree = false) for price in prices
    if checkFree != false then checkFree = true
    @freeCheckbox.prop('checked', checkFree)


