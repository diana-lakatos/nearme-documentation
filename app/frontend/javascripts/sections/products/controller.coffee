SpacePhotosController = require('../space/controller')

module.exports = class ProductController

  constructor: (@container, @options = {}) ->
    @photosContainer = $('.photos-container')
    @siblingListingsCarousel = @container.find('#listing-siblings-container')
    @fullScreenGallery = @container.find('#photos-container-enlarged')
    @fullScreenGalleryTrigger = @container.find('button[data-gallery-enlarge]')
    @fullScreenGalleryContainer = @container.find('#fullscreen-gallery')

    @setupCarousel()
    #@setupPhotos()
    @_bindEvents()
    @adjustFullGalleryHeight()

  _bindEvents: ->
    $(window).resize =>
      @adjustFullGalleryHeight()

    @siblingListingsCarousel.on 'slid.bs.carousel', =>
      currentSlide = @siblingListingsCarousel.find('.item.active').eq(0)
      @container.find('.other-listings header p a').text(currentSlide.data('listing-name')).attr('href', currentSlide.data('listing-url'))

    @fullScreenGalleryTrigger.on 'click', =>
      setTimeout ( =>
        @adjustFullGalleryHeight()
      ), 1200

    @fullScreenGalleryContainer.on "show", (e) =>
      @loadFullGalleryPhotos()

    @container.find('#products-tabs ul li a').on 'click', (e) ->
      e.preventDefault()
      $(this).tab('show')


  loadFullGalleryPhotos: ->
    @fullScreenGalleryContainer.find(".loading").show()
    carousel = $(this).find(".carousel").hide()
    deferreds = []
    imgs = @fullScreenGalleryContainer.find(".carousel .item", this).find("img")

    # loop over each img
    imgs.each ->
      self = $(this)
      datasrc = self.attr("data-src")
      if datasrc
        d = $.Deferred()
        self.one("load", d.resolve).attr("src", datasrc).attr "data-src", ""
        deferreds.push d.promise()

    $.when.apply($, deferreds).done =>
      @fullScreenGalleryContainer.find(".loading").hide()
      carousel.fadeIn 1000

  adjustFullGalleryHeight: ->
    @fullScreenGallery.find('.item img').removeClass('smaller-size')
    if @fullScreenGallery.find('.item.active img').height() >= $(window).height()
      @fullScreenGallery.height($(window).height())
      @fullScreenGallery.find('.item img').addClass('smaller-size')
    else
      @fullScreenGallery.height('auto')

  setupPhotos: ->
    @photos = new SpacePhotosController($('.space-hero-photos'))

  setupCarousel: ->
    carouselContainer = $(".carousel")
    return unless carouselContainer.length > 0
    carouselContainer.carousel({
      pills: false,
      wrap: true,
      interval: 10000
    })
