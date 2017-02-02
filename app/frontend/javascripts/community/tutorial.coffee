module.exports = class Tutorial
  constructor: (el) ->
    @root = $(el)
    @body = $('body')
    @slides = @root.find('.slide')
    @mask = @root.find('.mask')
    @current = @slides.index(@slides.filter('.is-active'))

    @initializeEvents()

    setTimeout(@init.bind(this), 10)

  init: ->
    @open() if @root.is('.is-active')

  show: (index) ->
    @slides.removeClass 'is-active'

    $next = @slides.eq(index)
    $target = $($next.data('mask'))
    $next.addClass 'is-active'

    bounds = $target.offset()
    width = $target.outerWidth()
    height = $target.outerHeight()

    doc_width = $(document).outerWidth()
    doc_height = $(document).outerHeight()

    top = bounds.top
    left = bounds.left
    right = doc_width - (bounds.left) - width
    bottom = doc_height - (bounds.top) - height

    @mask.css 'border-width', top + 'px ' + right + 'px ' + bottom + 'px ' + left + 'px'
    @current = index

  open: ->
    @root.addClass 'is-active'
    @body.addClass 'is-tutorial'
    @show(@current)

  close: ->
    @root.removeClass 'is-active'
    @body.removeClass 'is-tutorial'

  initializeEvents: ->
    $(window).on 'resize.tutorial', $.proxy ((event) ->
      return unless trueResize()
      @show(@current)
    ), this

    @root.on 'click', '[data-next]', $.proxy ((event) ->
      event.preventDefault()
      @show(@current + 1)
    ), this

    @root.find('[data-close]').on 'click', $.proxy ((event) ->
      event.preventDefault()
      @close()
    ), this

  @initialize: ->
    $('.tutorial-a').each ->
      new Tutorial(this)
