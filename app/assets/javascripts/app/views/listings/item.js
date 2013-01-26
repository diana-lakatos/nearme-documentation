define(['jquery', 'backbone', 'hbs!templates/listings/item'], function($, Backbone, listingTemplate) {
  var ListingView = Backbone.View.extend({
    template: listingTemplate,
    initialize: function() {
      _.bindAll(this, 'render');
    },

    events: {
      "click header": "toggleAction",
      "click .listing-delete": "trash"
    },

    render: function() {
      this.setElement(this.template(this.model.toJSON()));
      return this;
    },

    toggleAction: function(event) {
      var field = $(event.currentTarget);
      $(".action", field).toggle();
    },

    trash: function(event) {
      var result = confirm("Are you sure you want to delete this Listing?");
      if (result === true) {
        this.model.trash();
        this.$el.fadeOut();
      }
    }

  });
  return ListingView;

});

