class @Dashboard.Controller

  HEADER_SPACE_FROM_ICO_EDIT = 25

  constructor: (@container) ->
    @bindEvents()
    @locationHeader = @container.find('header.location').eq(0)
    @locationIcoWidth = @getEntityIcoWidth(@locationHeader)
    @locationEditIcoWidth = @getEditLocationIcoWidth()
    @listingHeader = @container.find('header.listing .listing-header').eq(0).parent()
    @listingIcoWidth = @getEntityIcoWidth(@listingHeader)
    @listingEditIcoWidth = @getEditListingIcoWidth()

    @setMaxWidth()

  bindEvents: =>
    $(window).resize =>
      @setMaxWidth()


  setMaxWidth: =>
    @container.find('header.location .entity-name').css('maxWidth', (@locationHeader.width() - @getReservedWidthForLocation()) + 'px')
    @container.find('header.listing .entity-name').css('maxWidth', (@listingHeader.width() - @getReservedWidthForListing()) + 'px')

  getEntityIcoWidth: (el) =>
    span_with_entity_ico_width = el.find('> span').outerWidth(true)
    
    target_width = el.find('.entity-name').width()
    span_with_entity_ico_width - target_width

  getReservedWidthForLocation: =>
     @locationIcoWidth + @locationEditIcoWidth

  getReservedWidthForListing: =>
     @listingIcoWidth + @listingEditIcoWidth


  getEditLocationIcoWidth: =>
    ico_icon = @locationHeader.find('.ico-edit')
    if ico_icon.length > 0
      24 + HEADER_SPACE_FROM_ICO_EDIT # better would be, but this returns wrong value: @locationHeader.find('.ico-edit').width()
    else
      0

  getEditListingIcoWidth: =>
    ico_icon = @listingHeader.find('.ico-edit')
    if ico_icon.length > 0
      20 + HEADER_SPACE_FROM_ICO_EDIT # better would be, but this returns wrong value: @listingHeader.find('.ico-edit').width()
    else
      0

