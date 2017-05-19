/* global google */
var GoogleMapMarker, GoogleMapPopover, SmartGoogleMap, SpaceController, SpacePhotosController;

SpacePhotosController = require('./photos_controller');

SmartGoogleMap = require('../../components/smart_google_map');

GoogleMapMarker = require('../../components/google_map_marker');

GoogleMapPopover = require('../../components/google_map_popover');

SpaceController = function() {
  function SpaceController(container) {
    this.container = container;
    this.mapAndPhotosContainer = $('.location-photos');
    this.photosContainer = $('.photos-container');
    this.mapContainer = $('.map');
    this.googleMapElementWrapper = this.mapContainer.find('.map-container');
    this.siblingListingsCarousel = this.container.find('#listing-siblings-container');
    this.fullScreenGallery = this.container.find('#photos-container-enlarged');
    this.fullScreenGalleryTrigger = this.container.find('button[data-gallery-enlarge]');
    this.fullScreenGalleryContainer = this.container.find('#fullscreen-gallery');
    this.setupCollapse();
    this.setupCarousel();
    this.setupMap();
    this.setupPhotos();
    this._bindEvents();
    this.adjustBookingModulePosition();
    this.adjustFullGalleryHeight();
  }

  SpaceController.prototype._bindEvents = function() {
    this.container.on('click', '[data-behavior=scrollToBook]', function(event) {
      event.preventDefault();
      return $('html, body').animate({ scrollTop: $('.bookings').offset().top - 20 }, 300);
    });
    $(window).resize(
      function(_this) {
        return function() {
          _this.adjustBookingModulePosition();
          return _this.adjustFullGalleryHeight();
        };
      }(this)
    );
    this.fullScreenGalleryContainer.on(
      'slid.bs.carousel',
      function(_this) {
        return function() {
          _this.adjustFullGalleryHeight();

          /*
         * To call modal's resize handlers
         */
          return $(window).resize();
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
    this.container.on(
      'click',
      '.amenities-header a',
      function(_this) {
        return function(event) {
          return _this.toggleAmenities(event);
        };
      }(this)
    );
    return this.container.on('click', '[data-booking-trigger]', function(event) {
      event.preventDefault();
      $(event.target).closest('[data-toggleable-booking-module]').toggleClass('collapsed');
      $(event.target).closest('.booking-module').find('select').trigger('render');
      if (
        $(event.target)
          .closest('[data-toggleable-booking-module]')
          .find('.pricing-tabs li.active').length ===
          0
      ) {
        return $(event.target)
          .closest('[data-toggleable-booking-module]')
          .find('.pricing-tabs a.possible:first')
          .click();
      }
    });
  };

  SpaceController.prototype.loadFullGalleryPhotos = function() {
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
          carousel.fadeIn(1000);
          return $(window).resize();
        };
      }(this)
    );
  };

  SpaceController.prototype.adjustBookingModulePosition = function() {
    /*
     * 610 - booking module breakpoint
     */
    if ($(window).width() <= 610) {
      /*
       * move booking module below photos gallery and add some padding
       */
      return this.container
        .find('.listings')
        .addClass('padding-row')
        .appendTo(this.container.find('article.photos'));
    } else {
      return this.container
        .find('.listings')
        .removeClass('padding-row')
        .appendTo(this.container.find('article.booking'));
    }
  };

  SpaceController.prototype.adjustFullGalleryHeight = function() {
    this.fullScreenGallery.find('.item img').removeClass('smaller-size');
    if (this.fullScreenGallery.find('.item.active img').height() >= $(window).height()) {
      this.fullScreenGallery.height($(window).height());
      return this.fullScreenGallery.find('.item img').addClass('smaller-size');
    } else {
      return this.fullScreenGallery.height('auto');
    }
  };

  SpaceController.prototype.setupPhotos = function() {
    return this.photos = new SpacePhotosController($('.space-hero-photos'));
  };

  SpaceController.prototype.setupMap = function() {
    var latlng, location, mapTypeId, marker;
    if (!(this.mapContainer.length > 0)) {
      return;
    }
    location = this.mapContainer.find('address');
    latlng = new google.maps.LatLng(location.attr('data-lat'), location.attr('data-lng'));
    mapTypeId = google.maps.MapTypeId.ROADMAP;
    this.map = { map: null, markers: [] };
    this.map.initialCenter = latlng;
    this.map.map = SmartGoogleMap.createMap(this.googleMapElementWrapper[0], {
      zoom: 13,
      zoomControlOptions: { style: google.maps.ZoomControlStyle.SMALL },
      mapTypeControl: false,
      panControl: false,
      streetViewControl: false,
      center: latlng,
      mapTypeId: mapTypeId
    });
    marker = new google.maps.Marker({
      position: latlng,
      map: this.map.map,
      icon: GoogleMapMarker.getMarkerOptions()['default'].image,
      shadow: null,
      shape: GoogleMapMarker.getMarkerOptions()['default'].shape
    });
    this.map.markers.push(marker);
    this.popover = new GoogleMapPopover({
      'boxStyle': { 'width': '190px' },
      'pixelOffset': new google.maps.Size(-95, -40)
    });
    this.popover.setContent(this.mapContainer.find('address').html());

    /*
     * $.browser is no longer supported, removing as bug, but not sure about condition itself in IE10+ ?
     * if ($.browser.msie && parseInt($.browser.version) > 9)
     *   @popover.open(@map.map, marker)
     */
    return google.maps.event.addListener(
      marker,
      'click',
      function(_this) {
        return function() {
          return _this.popover.open(_this.map.map, marker);
        };
      }(this)
    );
  };

  SpaceController.prototype.setupCarousel = function() {
    var carouselContainer;
    carouselContainer = $('.carousel');
    if (!(carouselContainer.length > 0)) {
      return;
    }
    return carouselContainer.carousel({ pills: false, wrap: true, interval: 10000 });
  };

  SpaceController.prototype.setupCollapse = function() {
    var collapseContainer;
    collapseContainer = $('.accordion');
    if (!(collapseContainer.length > 0)) {
      return;
    }
    collapseContainer.on('show hide', function() {
      return $(this).css('height', 'auto');
    });
    return collapseContainer.collapse({ parent: true, toggle: true });
  };

  SpaceController.prototype.toggleAmenities = function(event) {
    var amenities_block, amenities_header;
    amenities_header = $(event.target).closest('.amenities-header');
    amenities_block = amenities_header.closest('.amenities-block');
    amenities_header
      .find('a span')
      .toggleClass('ico-chevron-right')
      .toggleClass('ico-chevron-down');
    amenities_block.toggleClass('amenities-shown');
    return false;
  };

  return SpaceController;
}();

module.exports = SpaceController;
