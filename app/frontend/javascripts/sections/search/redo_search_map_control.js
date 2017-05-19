/* global google */
var SearchRedoSearchMapControl, asEvented;

asEvented = require('asevented');

SearchRedoSearchMapControl = function() {
  asEvented.call(SearchRedoSearchMapControl.prototype);

  SearchRedoSearchMapControl.prototype.template = function(update_text) {
    return "<div> <label><input type='checkbox' /> " + update_text + '</label> </div>';
  };

  function SearchRedoSearchMapControl(options) {
    if (options == null) {
      options = {};
    }
    this.controlDiv = $('<div/>');
    this.controlDiv.addClass('search-map-redo-search-control');
    this.controlDiv.html(this.template(options.update_text));
    this.input = this.controlDiv.find('input');
    this.input.prop('checked', !!options.enabled);
    this.bindEvents();
  }

  SearchRedoSearchMapControl.prototype.bindEvents = function() {
    return this.input.on(
      'change',
      function(_this) {
        return function() {
          return _this.trigger('stateChanged', _this.isEnabled());
        };
      }(this)
    );
  };

  SearchRedoSearchMapControl.prototype.isEnabled = function() {
    return this.input.is(':checked');
  };

  SearchRedoSearchMapControl.prototype.isDisabled = function() {
    return !this.isEnabled();
  };

  SearchRedoSearchMapControl.prototype.setMap = function(googleMap) {
    return googleMap.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(this.getContainer());
  };

  SearchRedoSearchMapControl.prototype.getContainer = function() {
    return this.controlDiv[0];
  };

  return SearchRedoSearchMapControl;
}();

module.exports = SearchRedoSearchMapControl;
