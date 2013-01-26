define(['jquery', 'backbone','Collections/listing', 'Views/listings/item', 'hbs!templates/locations/item'], function($, Backbone, listingCollection, ListingView, locationTemplate) {
  var LocationView = Backbone.View.extend({
    template: locationTemplate,
    initialize: function() {
      _.bindAll(this, 'render','addAll','addOne');
      this.listingCollection = new listingCollection(this.model.get('listings'));
    },

    events: {
      "click header": "toggleAction",
      "click .delete": "trash"
    },

    render: function() {
      this.setElement(this.template(this.model.toJSON()));
      this.addAll();
      return this;
    },

    addAll: function() {
      this.listingCollection.each(this.addOne);
    },

    addOne: function(listing) {
        var view = new ListingView({model: listing});
        var hookElt = '#location-' + this.model.id + '-listings-holder';
        $(this.$el).find(hookElt).append(view.render().el);
      },

    toggleAction: function(event) {
      var field = $(event.currentTarget);
      $(".action", field).toggle();
    },

    trash: function(event) {
      var result = confirm("Are you sure you want to delete this Space?");
      if (result === true) {
        this.model.trash();
        this.$el.fadeOut();
      }
    }
  });
  return LocationView;

});
