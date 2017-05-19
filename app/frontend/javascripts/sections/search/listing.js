/* global google */
var SearchListing, asEvented;

asEvented = require('asevented');

/*
 * A simple wrapper around the search result data
 *
 * TODO: At some point we should probalby be retrieving JSON result data rather than
 *       HTML elements.
 */
SearchListing = function() {
  asEvented.call(SearchListing.prototype);

  SearchListing.forElement = function(el) {
    var listing;
    el = $(el);
    listing = el.data('mapListing');
    listing || (listing = new SearchListing(el));
    el.data('mapListing', listing);
    return listing;
  };

  function SearchListing(element) {
    this._element = $(element);
    this._id = parseInt(this._element.data('id'), 10);
    this._lat = parseFloat(this._element.data('latitude')) || 0;
    this._lng = parseFloat(this._element.data('longitude')) || 0;
    this._location = parseInt(this._element.data('location'));
    this._name = this._element.attr('data-name');
    this.bindEvents();
  }

  /*
   * The current implementation of the search results use server-side generated html elements.
   * Since these can change, we want to swap the element we're bound to but still refer to the
   * same client-side Listing object to simplify our event binding and behaviour
   */
  SearchListing.prototype.setElement = function(element) {
    if (this._element[0] !== $(element)[0]) {
      this._element = $(element);
      return this.bindEvents();
    }
  };

  SearchListing.prototype.setHtml = function(html) {
    this._element.replaceWith(html);
    return this.setElement(html);
  };

  SearchListing.prototype.bindEvents = function() {};

  SearchListing.prototype.element = function() {
    return this._element;
  };

  SearchListing.prototype.id = function() {
    return this._id;
  };

  SearchListing.prototype.lat = function() {
    return this._lat;
  };

  SearchListing.prototype.lng = function() {
    return this._lng;
  };

  SearchListing.prototype.name = function() {
    return this._name;
  };

  SearchListing.prototype.latLng = function() {
    return this._latLng || (this._latLng = new google.maps.LatLng(this._lat, this._lng));
  };

  SearchListing.prototype.location = function() {
    return this._location;
  };

  /*
   * The content that goes in the map popup when clicking the marker
   */
  SearchListing.prototype.popoverContent = function() {
    return this._element.find('.listing-map-popover-content').html();
  };

  SearchListing.prototype.popoverTitleContent = function() {
    return this._element.find('.listing-location-title').html();
  };

  /*
   * Don't show this result.
   */
  SearchListing.prototype.hide = function() {
    return this._element.hide().addClass('hidden');
  };

  return SearchListing;
}();

module.exports = SearchListing;
