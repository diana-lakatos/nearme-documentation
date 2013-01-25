define(['jquery', 'backbone', 'hbs!templates/locations/item'], function($, Backbone, locationTemplate) {
  var LocationView = Backbone.View.extend({
    template: locationTemplate,
    initialize: function() {
      _.bindAll(this, 'render');
    },

    events: {
      "click header": "toggleAction",
      "click .delete": "trash"
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
      var result = confirm("Are you sure you want to delete this Space?");
      if (result === true) {
        this.model.trash();
        this.$el.fadeOut();
      }
    }

  });
  return LocationView;

});

