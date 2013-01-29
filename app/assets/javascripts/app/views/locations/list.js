define(['jquery', 'backbone', 'collections/location', 'models/location', 'views/locations/item', 'hbs!templates/locations/list', 'bootstrap'], function($, Backbone, LocationCollection, LocationModel, LocationView, locationListTemplate) {
  var Locations = Backbone.View.extend({
    el: '#dyn-content',
    template: locationListTemplate,
    initialize: function() {
      _.bindAll(this, 'render', 'addAll', 'addOne', 'createLocation');
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

    events: {
      "click .add-location": "createLocation"
    },

    createLocation: function()
    {
      event.preventDefault();
      event.stopPropagation();
      var locationModel = new LocationModel({name: 'New location'});
      this.addOne(locationModel);
    },

    addAll: function() {
      this.collection.each(this.addOne);
    },

    addOne: function(locationModel) {
        var view = new LocationView({ model: locationModel });
        $(this.$el).children('.locations-holder').prepend(view.render().el);
      },

    render: function() {
      if (this.collection) {
        this.$el.html(this.template());
        this.addAll();
        $(".collapse").collapse();
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
