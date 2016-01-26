module.exports = class Dialog

  constructor: ()->
    @build()
    @bindEvents()

  build: ->
    @dialog = $('<div class="dialog" role="dialog" aria-hidden="true" aria-describedby="dialog__title"><div class="dialog__overlay"></div><div class="dialog__container"><div class="dialog__content"></div><button type="button" data-modal-close class="dialog__close">Close</button></div></div>')
    @overlay = @dialog.find('.dialog__overlay')
    @contentHolder = @dialog.find('.dialog__content')
    $('body').append(@dialog)

  bindEvents: ->
    @dialog.on 'click', '[data-modal-close]', (e)=>
      e.preventDefault()
      @hide()

    # Click on modal button trigger

    $('body').on 'click', 'a[data-modal]', (e) =>
      e.preventDefault()
      e.stopPropagation()
      target = $(e.currentTarget)
      ajaxOptions = { url: target.attr("href"), data: target.attr('data-ajax-options') }
      @load(ajaxOptions, target.attr('data-modal-class'))

    # submit form via button
    $('body').on 'submit', 'form[data-modal]', (e) =>
      e.preventDefault()
      form = $(e.currentTarget)
      ajaxOptions = { type: form.attr('method'), url: form.attr("action"), data: form.serialize()}
      @load(ajaxOptions, form.attr('data-modal-class'))

    $('html').on 'hide.dialog', =>
      @hide()

    $('html').on 'load.dialog', (event, ajaxOptions = {}, klass = null)=>
      @load(ajaxOptions, klass)

    @overlay.on 'click', =>
      @hide()

  load: (ajaxOptions, klass)=>
    @setClass(klass)
    @showLoading()
    @show()

    $.ajax(ajaxOptions).success (data) =>

      if data.redirect
        window.location = data.redirect
      else if data.hide
        @hide()
      else
        @showContent(data)

  show: =>
    $('body').addClass('dialog--visible')
    @dialog.attr('aria-hidden', false)

    @bindEscapeKey()

  showLoading: =>
    @dialog.removeClass('dialog--loaded')

  showContent: (content)=>
    @contentHolder.html(content)
    @dialog.addClass('dialog--loaded')
    $('html').trigger('loaded.dialog')

  hide: =>
    @dialog.attr('aria-hidden', true)
    $('body').removeClass('dialog--visible')
    $('body').off('keydown.dialog')

  bindEscapeKey: =>
    $('body').on 'keydown.dialog', (e)=>
      return unless e.which == 27
      @hide()

  setClass: (klass)=>
    return unless klass
    @dialog.removeClass(@customClass) if @customClass
    @customClass = klass
    @dialog.add(@customClass)
