module.exports = class Dialog

  constructor: ->
    @build()
    @bindEvents()

  build: ->
    @dialog = $("""
      <div class='dialog' role='dialog' aria-hidden='true' aria-describedby='dialog__title'>
        <div class='dialog__overlay'>
        </div>
        <div class='dialog__container'>
          <div class='dialog__content'></div>
            <button type='button' data-modal-close class='dialog__close'>Close</button>
          </div>
      </div>""")
    @overlay = @dialog.find('.dialog__overlay')
    @contentHolder = @dialog.find('.dialog__content')
    $('body').append(@dialog)

  bindEvents: ->
    @resetCallbacks()

    @dialog.on 'click', '[data-modal-close]', (e) =>
      e.preventDefault()
      @hide()

    # Click on modal button trigger

    $('body').on 'click.nearme', 'a[data-modal]', (e) =>
      e.preventDefault()
      e.stopPropagation()
      target = $(e.currentTarget)
      ajaxOptions = { url: target.attr('href'), data: target.data('ajax-options') }
      @load(ajaxOptions, target.data('modal-class'))

    # submit form via button
    $('body').on 'submit.nearme', 'form[data-modal]', (e) =>
      e.preventDefault()
      form = $(e.currentTarget)
      ajaxOptions = { type: form.attr('method'), url: form.attr('action'), data: new FormData(e.currentTarget), processData: false, contentType: false }
      @load(ajaxOptions, form.data('modal-class'))

    $(document).on 'hide:dialog.nearme', =>
      @hide()

    $(document).on 'load:dialog.nearme', (event, ajaxOptions = {}, klass = null, callbacks = {}) =>
      @load(ajaxOptions, klass, callbacks)

    @overlay.on 'click', =>
      @hide()

  resetCallbacks: ->
    @callbacks = {
      onShow: (->)
      onHide: (->)
    }

  load: (ajaxOptions, klass, callbacks = {}) =>
    @resetCallbacks()
    @callbacks = $.extend({}, @callbacks, callbacks)
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

  showContent: (content) =>
    @contentHolder.html(content)
    @dialog.addClass('dialog--loaded')
    $('html').trigger('loaded:dialog.nearme')
    @callbacks.onShow()

  hide: =>
    @dialog.attr('aria-hidden', true)
    $('body').removeClass('dialog--visible')
    $('body').off('keydown.dialog')
    @callbacks.onHide()


  bindEscapeKey: =>
    $('body').on 'keydown.dialog', (e) =>
      return unless e.which == 27
      @hide()

  setClass: (klass) =>
    @dialog.removeClass(@customClass) if @customClass
    return unless klass
    @customClass = klass
    @dialog.addClass(@customClass)
