var ProductController, SpacePhotosController;

SpacePhotosController = require('../space/controller');

ProductController = function() {
  function ProductController(container, options) {
    this.container = container;
    this.options = options != null ? options : {};
    this.photosContainer = $('.photos-container');
    this.siblingListingsCarousel = this.container.find('#listing-siblings-container');
    this.fullScreenGallery = this.container.find('#photos-container-enlarged');
    this.fullScreenGalleryTrigger = this.container.find('button[data-gallery-enlarge]');
    this.fullScreenGalleryContainer = this.container.find('#fullscreen-gallery');
    this.setupCarousel();

    /*
    #@setupPhotos()
     */
    this._bindEvents();
    this.adjustFullGalleryHeight();
  }

  ProductController.prototype._bindEvents = function() {
    $(window).resize(
      function(_this) {
        return function() {
          return _this.adjustFullGalleryHeight();
        };
      }(this)
    );
    this.siblingListingsCarousel.on(
      'slid.bs.carousel',
      function(_this) {
        return function() {
          var currentSlide;
          currentSlide = _this.siblingListingsCarousel.find('.item.active').eq(0);
          return _this.container
            .find('.other-listings header p a')
            .text(currentSlide.data('listing-name'))
            .attr('href', currentSlide.data('listing-url'));
        };
      }(this)
    );
    this.fullScreenGalleryTrigger.on(
      'click',
      function(_this) {
        return function() {
          return setTimeout(
            function() {
              return _this.adjustFullGalleryHeight();
            },
            1200
          );
        };
      }(this)
    );
    this.fullScreenGalleryContainer.on(
      'show',
      function(_this) {
        return function() {
          return _this.loadFullGalleryPhotos();
        };
      }(this)
    );
    return this.container.find('#products-tabs ul li a').on('click', function(e) {
      e.preventDefault();
      return $(this).tab('show');
    });
  };

  ProductController.prototype.loadFullGalleryPhotos = function() {
    var carousel, deferreds, imgs;
    this.fullScreenGalleryContainer.find('.loading').show();
    carousel = $(this).find('.carousel').hide();
    deferreds = [];
    imgs = this.fullScreenGalleryContainer.find('.carousel .item', this).find('img');

    /*
     * loop over each img
     */
    imgs.each(function() {
      var d, datasrc, self;
      self = $(this);
      datasrc = self.attr('data-src');
      if (datasrc) {
        d = $.Deferred();
        self.one('load', d.resolve).attr('src', datasrc).attr('data-src', '');
        return deferreds.push(d.promise());
      }
    });
    return $.when.apply($, deferreds).done(
      function(_this) {
        return function() {
          _this.fullScreenGalleryContainer.find('.loading').hide();
          return carousel.fadeIn(1000);
        };
      }(this)
    );
  };

  ProductController.prototype.adjustFullGalleryHeight = function() {
    this.fullScreenGallery.find('.item img').removeClass('smaller-size');
    if (this.fullScreenGallery.find('.item.active img').height() >= $(window).height()) {
      this.fullScreenGallery.height($(window).height());
      return this.fullScreenGallery.find('.item img').addClass('smaller-size');
    } else {
      return this.fullScreenGallery.height('auto');
    }
  };

  ProductController.prototype.setupPhotos = function() {
    return this.photos = new SpacePhotosController($('.space-hero-photos'));
  };

  ProductController.prototype.setupCarousel = function() {
    var carouselContainer;
    carouselContainer = $('.carousel');
    if (!(carouselContainer.length > 0)) {
      return;
    }
    return carouselContainer.carousel({ pills: false, wrap: true, interval: 10000 });
  };

  return ProductController;
}();

module.exports = ProductController;
