define(['jquery', 'backbone', 'collections/listing', 'hbs!templates/listings/list','bootstrap'], function($, Backbone,ListingCollection, listingListTemplate) {
  var listings = Backbone.View.extend({
    id: "dyn-content",
    template: listingListTemplate,
    initialize: function() {
      _.bindAll(this, 'addlisting');
      this.locationId = this.options.locationId;
      // Display a loading indication whenever the Collection is fetching.
    },

    _setCollection: function() {
      this.collection = new ListingCollection();
      this.collection.on("fetch", function() {
        this.$el.html("<img src='/assets/images/spinner.gif'>");
      }, this);

      // Automatically re-render whenever the Collection is populated.
      this.collection.on("reset", this.render, this);
      this.collection.fetch();
    },

    events: {
      "click .load-item": "load"
    },

    newlisting: function(event) {
      event.preventDefault();
      Backbone.Events.trigger("listings:new");
      /* // Create the modal view*/
      var view = new NewlistingView({
        callback: this.addlisting
      });
      $('#modal').html(view.render().el);
      $('#modal').modal();
    },

    render: function() {
      if (this.collection) {
        var self = this;
        $('#dyn-content').html(this.template({ info: this.collection.toJSON() }));
        $(".collapse").collapse();
        this.setElement("#dyn-content");
      } else {
        this._setCollection();
      }
      return this;
    },

    load: function() {
      // list listing for this listing and display in "listing-for-{{listing-id}}" element
      alert("loading");
    }
  });
  return listings;

});
