class @SpacePhotosController

  constructor: (@container) ->
    @photo = @container.find('.photo')
    @caption = @container.find('.caption')

    @listContainer = @container.find('.photos-list')
    @listPrev = @listContainer.find('.prev')
    @listNext = @listContainer.find('.next')
    @listWrapper = @listContainer.find('.photos-wrapper')
    @list = @listContainer.find('ul')

    @bindEvents()

    @showPhoto(@list.find('li').eq(0))

  bindEvents: ->
    @list.on 'click', 'li', (event) =>
      @showPhoto($(event.target).closest('li'))

    @listPrev.on 'click', => @prev()
    @listNext.on 'click', => @next()


  prev: ->
    prev = @list.find('li.selected').prev()
    if prev.length > 0
      @showPhoto(prev)

  next: ->
    next = @list.find('li.selected').next()
    if next.length > 0
      @showPhoto(next)

  hasNext: ->
    @list.find('li.selected').next().length > 0

  hasPrev: ->
    @list.find('li.selected').prev().length > 0

  updatePrevNext: ->
    if @hasNext()
      @listNext.css('visibility', 'visible')
    else
      @listNext.css('visibility', 'hidden')

    if @hasPrev()
      @listPrev.css('visibility', 'visible')
    else
      @listPrev.css('visibility', 'hidden')


  centerListView: ->
    photos = @list.find('li')
    selected = photos.filter('.selected').eq(0)

    count = photos.length
    index = photos.index(selected)

    offsetPos = if index <= 1
      0
    else if index < (count - 1)
      index - 1
    else
      index - 2

    offset = offsetPos * selected.outerHeight(true)
    @list.animate({
      'margin-top': "-#{offset}px"
    }, 'fast')

  showPhoto: (listItem) ->
    console.info listItem.find('img')

    @photo.css({
      backgroundImage: "url('#{listItem.find('img').attr('data-url')}')"
    })
    @caption.text(listItem.find('img').attr('alt'))
    listItem.siblings().removeClass("selected")
    listItem.addClass("selected")

    @centerListView()
    @updatePrevNext()

