/* global google */
var GoogleMapMarker, GoogleMapPopover, MarkerClusterer, SearchMap, SmartGoogleMap, asEvented;

asEvented = require('asevented');

MarkerClusterer = require('../../../vendor/markerclusterer');

SmartGoogleMap = require('../../components/smart_google_map');

GoogleMapPopover = require('../../components/google_map_popover');

GoogleMapMarker = require('../../components/google_map_marker');

/*
 * Encapsulates the map behaviour for the serach results
 */
SearchMap = function() {
  var GOOGLE_MAP_OPTIONS;

  asEvented.call(SearchMap.prototype);

  GOOGLE_MAP_OPTIONS = {
    zoom: 12,
    minZoom: 4,
    maxZoom: 18,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: true,
    zoomControl: true
  };

  GOOGLE_MAP_OPTIONS.clusterer = {
    maxZoom: GOOGLE_MAP_OPTIONS.maxZoom + 1,
    averageCenter: true,
    minimumClusterSize: 1,
    styles: [
      { width: 22, height: 22, url: 'assets/images/transparent.png' },
      { width: 26, height: 26, url: 'assets/images/transparent.png' },
      { width: 36, height: 36, url: 'assets/images/transparent.png' }
    ],
    calculator: function(markers, numStyles) {
      var idx;
      idx = MarkerClusterer.CALCULATOR(markers, numStyles).index;
      return { index: idx, text: markers.length.toString(), title: markers.length.toString() };
    }
  };

  function SearchMap(container, controller) {
    this.container = container;
    this.initializeGoogleMap();
    this.bindEvents();
    this.loading = false;
    this.current_position = {
      getPosition: function() {
        return {};
      }
    };
    this.search_controller = controller;
  }

  SearchMap.prototype.initializeGoogleMap = function() {
    this.googleMap = SmartGoogleMap.createMap(this.container, GOOGLE_MAP_OPTIONS, {
      exclude: [ 'draggable' ]
    });
    this.clusterer = new MarkerClusterer(this.googleMap, [], GOOGLE_MAP_OPTIONS.clusterer);

    /*
     * Info window pops over and contains details for each marker/listing
     */
    this.popover = new GoogleMapPopover();

    /*
     * need to toggle scroll wheel because of overflow: auto
     * need to remember which cluster has been open to prevent re-opening the same one
     */
    this.popover.on(
      'closed',
      function(_this) {
        return function() {
          _this.googleMap.setOptions({ scrollwheel: true });
          $(_this.container).removeClass('popover-opened');
          return _this.current_position = {};
        };
      }(this)
    );
    this.popover.on(
      'opened',
      function(_this) {
        return function() {
          $(_this.container).addClass('popover-opened');
          _this.googleMap.setOptions({ scrollwheel: false });
          return _this.current_position = _this.current_cluster_position;
        };
      }(this)
    );
    return this.resetMapMarkers();
  };

  SearchMap.prototype.bindEvents = function() {
    /*
     * Ensure the map is notified of window resize, and positioning adjusted.
     */
    $(window).resize(
      function(_this) {
        return function() {
          return google.maps.event.trigger(_this.googleMap, 'resize');
          /*
         * NB: We don't update the map bounds here as the mobile UI's seemingly do
         * minor dimension changes during scrolling resulting in poor UX if we modify
         * the map bounds which triggers viewportChanged callbacks.
         */
        };
      }(this)
    );
    google.maps.event.addListener(
      this.googleMap,
      'dragend',
      function(_this) {
        return function() {
          return _this.trigger('viewportChanged');
        };
      }(this)
    );
    google.maps.event.addListener(
      this.googleMap,
      'zoom_changed',
      function(_this) {
        return function() {
          _this.trigger('viewportChanged');
          _this.clusterer.setZoomOnClick(_this.googleMap.getZoom() < GOOGLE_MAP_OPTIONS.maxZoom);
          return _this.popover.close();
        };
      }(this)
    );
    google.maps.event.addListener(
      this.googleMap,
      'click',
      function(_this) {
        return function() {
          _this.popover.close();
          return _this.trigger('click');
        };
      }(this)
    );
    this.clusterer.addListener(
      'mouseover',
      function(_this) {
        return function(cluster) {
          return _.defer(function() {
            return _this.showInfoWindowForCluster(cluster);
          });
        };
      }(this)
    );
    this.clusterer.addListener(
      'click',
      function(_this) {
        return function(cluster) {
          if (_this.googleMap.getZoom() < GOOGLE_MAP_OPTIONS.maxZoom) {
            return;
          }
          return _.defer(function() {
            return _this.showInfoWindowForCluster(cluster);
          });
        };
      }(this)
    );
    return null;
  };

  /*
   * Adds one of our custom map controls to the map
   */
  SearchMap.prototype.addControl = function(control) {
    return control.setMap(this.googleMap);
  };

  /*
   * Clears any plotted listings and resets the map
   */
  SearchMap.prototype.resetMapMarkers = function() {
    var listingId, marker, ref;
    if (this.markers) {
      ref = this.markers;
      for (listingId in ref) {
        marker = ref[listingId];
        marker.setMap(null);
      }
    }
    this.markers = {};
    this.listings = {};
    return this.initializeListingBounds();
  };

  SearchMap.prototype.initializeListingBounds = function() {
    var listingId, marker, ref, results;
    this.bounds = new google.maps.LatLngBounds();
    ref = this.markers;
    results = [];
    for (listingId in ref) {
      marker = ref[listingId];
      results.push(this.bounds.extend(marker.getPosition()));
    }
    return results;
  };

  SearchMap.prototype.removeListingsOutOfMapBounds = function() {
    var latLng, listingId, mapBounds, marker, ref;
    mapBounds = this.googleMap.getBounds();
    ref = this.markers;
    for (listingId in ref) {
      marker = ref[listingId];
      latLng = marker.getPosition();
      if (!mapBounds.contains(latLng)) {
        marker.setMap(null);
        delete this.markers[listingId];
      }
    }

    /*
     * Need to refresh the map bounds object since we've
     * removed listings.
     */
    return this.initializeListingBounds();
  };

  SearchMap.prototype.plotListings = function(listings) {
    var i, len, listing, results;
    results = [];
    for (i = 0, len = listings.length; i < len; i++) {
      listing = listings[i];
      results.push(this.plotListing(listing));
    }
    return results;
  };

  /*
   * Only plot a listing if it fits within the map bounds.
   * Returns whether or not a listing was plotted.
   */
  SearchMap.prototype.plotListingIfInMapBounds = function(listing) {
    var latLng;
    latLng = listing.latLng();
    if (this.googleMap.getBounds().contains(latLng)) {
      this.plotListing(listing);
      return true;
    } else {
      return false;
    }
  };

  SearchMap.prototype.plotListing = function(listing) {
    /*
     * Don't re-plot the same listing
     */
    var marker;
    if (this.markers[listing.id()]) {
      return;
    }
    marker = new google.maps.Marker({
      position: listing.latLng(),
      map: this.googleMap,
      title: listing.name(),
      visible: false,
      shadow: null,
      shape: GoogleMapMarker.getMarkerOptions()['default'].shape
    });
    this.markers[listing.id()] = marker;
    this.listings[listing.id()] = listing;
    this.bounds.extend(listing.latLng());
    this.clusterer.addMarker(marker);
    return marker.setVisible(true);
  };

  SearchMap.prototype.fitBounds = function(bounds) {
    return this.googleMap.fitBounds(bounds || this.bounds);
  };

  SearchMap.prototype.setCenter = function(latLng) {
    return this.googleMap.setCenter(latLng);
  };

  SearchMap.prototype.resizeToFillViewport = function() {
    var offset, viewport;
    offset = $(this.container).offset();
    viewport = $(window).height();
    $(this.container).height(viewport - offset.top);
    _.defer(
      function(_this) {
        return function() {
          return google.maps.event.trigger(_this.googleMap, 'resize');
        };
      }(this)
    );
    return true;
  };

  /*
   * Return an array of [nx, ny, sx, sy] coordinates
   */
  SearchMap.prototype.getBoundsArray = function() {
    var bounds, ne, sw;
    bounds = this.googleMap.getBounds();
    if (bounds) {
      ne = bounds.getNorthEast();
      sw = bounds.getSouthWest();
      return [ ne.lat(), ne.lng(), sw.lat(), sw.lng() ];
    } else {
      return [ 0, 0, 0, 0 ];
    }
  };

  SearchMap.prototype.getListingForMarker = function(marker) {
    var _marker, idx, listing_id, ref;
    listing_id = null;
    ref = this.markers;
    for (idx in ref) {
      _marker = ref[idx];
      if (_marker === marker) {
        listing_id = idx;
        break;
      }
    }
    return this.listings[listing_id];
  };

  SearchMap.prototype.showInfoWindowForCluster = function(cluster) {
    var listings, listingsByLocation;
    if (!this.loading && this.current_position !== cluster.center_) {
      this.current_cluster_position = cluster.center_;
      if (cluster.getMarkers().length > 100) {
        this.popover.setError('Maximum listings per marker is 100. Click the marker to zoom in.');
      } else {
        this.loading = true;
        this.popover.markAsBeingLoaded();
        listings = _.map(
          cluster.getMarkers(),
          function(_this) {
            return function(marker) {
              return _this.getListingForMarker(marker);
            };
          }(this)
        );
        listingsByLocation = _.groupBy(_.compact(listings), function(listing) {
          return listing.location();
        });
        _.defer(
          function(_this) {
            return function() {
              return _this.search_controller.updateListings(
                listings,
                function() {
                  var group, html, i, len, listing, location;
                  html = '';
                  for (location in listingsByLocation) {
                    group = listingsByLocation[location];
                    html += group[0].popoverTitleContent();
                    for (i = 0, len = group.length; i < len; i++) {
                      listing = group[i];
                      html += listing.popoverContent();
                    }
                  }
                  _this.popover.setContent(html);
                  return _this.loading = false;
                },
                function() {
                  _this.popover.setError('An error occured retrieving listings, please try again.');
                  return _this.loading = false;
                }
              );
            };
          }(this)
        );
      }
      this.popover.open(this.googleMap, {
        getPosition: function() {
          return cluster.center_;
        }
      });
    }
    return true;
  };

  SearchMap.prototype.showInfoWindowForListing = function(listing) {
    var marker;
    marker = this.markers[listing.id()];
    if (!marker) {
      return;
    }
    return this.search_controller.updateListing(
      listing,
      function(_this) {
        return function() {
          _this.popover.setContent(listing.popoverTitleContent() + listing.popoverContent());
          return _this.popover.open(_this.googleMap, marker);
        };
      }(this)
    );
  };

  SearchMap.prototype.show = function() {
    return $(this.container).show();
  };

  SearchMap.prototype.hide = function() {
    return $(this.container).hide();
  };

  return SearchMap;
}();

module.exports = SearchMap;
