define(['jquery', 'backbone', 'collections/location', 'hbs!templates/locations/list','bootstrap'], function($, Backbone, LocationCollection,  locationListTemplate) {
  var Locations = Backbone.View.extend({
    template: locationListTemplate,
    initialize: function() {
    },

    _setCollection: function() {
      this.collection = new LocationCollection();
      this.collection.on("fetch", function() {
        this.$el.html("<img src='/assets/images/spinner.gif'>");
      }, this);

      // Automatically re-render whenever the Collection is populated.
      this.collection.on("reset", this.render, this);
      this.collection.fetch();
    },

    /*events: {*/
      ////"click .location-header": "load"
    /*},*/

    newlocation: function(event) {
      event.preventDefault();
      Backbone.Events.trigger("locations:new");
      /* // Create the modal view*/
    },

    render: function() {
      if (this.collection) {
        var self = this;
        $('#dyn-content').html(this.template({ locations: this.collection.toJSON() }));
        $(".collapse").collapse();
        this.setElement("#dyn-content");
      } else {
        this._setCollection();
      }
      return this;
    }

    /*load: function(event) {*/
      //// list listing for this location and display in "listing-for-{{location-id}}" element
      //var locationId = $(event.target.data('id'));
      //var hookElt = '#listing-for-' + locationId;
      //var listingsView = new ListingsView({locationId : locationId});
      //$(hookElt).html(listingView.render());
    /*}*/
  });
  return Locations;

});
