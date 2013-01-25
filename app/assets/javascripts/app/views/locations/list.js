define(['jquery', 'backbone', 'collections/location','views/locations/item', 'hbs!templates/locations/list', 'bootstrap'], function($, Backbone, LocationCollection, LocationView, locationListTemplate) {
  var Locations = Backbone.View.extend({
    el: '#dyn-content',
    template: locationListTemplate,
    initialize: function() {
      _.bindAll(this, 'render', 'addAll', 'addOne');
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
      "click .add-location": "addlocation",
      "click .add-listing": "addlisting"
    },


    addlocation: function(event) {
      event.preventDefault();
      alert('create location triggered');
    },

    addlisting: function(event) {
      event.preventDefault();
      alert('create listing triggered');
    },

    addAll: function() {
      this.collection.each(this.addOne);
    },

    addOne: function(location) {
        var view = new LocationView({ model: location});
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
