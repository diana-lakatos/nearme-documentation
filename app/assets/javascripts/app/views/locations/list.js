//define(['jquery', 'backone', 'collections/location', 'views/locations/new', 'hbs!templates/locations/list'], function($, Backbone,locationCollection, NewlocationView, locationListTemplate) {
define(['jquery', 'backbone', 'collections/location', 'hbs!templates/locations/list','bootstrap'], function($, Backbone,locationCollection, locationListTemplate) {
  var Locations = Backbone.View.extend({
    id: "locationsView",
    template: locationListTemplate,
    initialize: function() {
      _.bindAll(this, 'addlocation');
      // Display a loading indication whenever the Collection is fetching.
    },

    _setCollection: function() {
      this.collection = new locationCollection();
      this.collection.on("fetch", function() {
        this.$el.html("<img src='/assets/images/spinner.gif'>");
      }, this);

      // Automatically re-render whenever the Collection is populated.
      this.collection.on("reset", this.render, this);
      this.collection.fetch();
    },

    events: {
      "click .location-destroy": "trash",
      "click .locationButton span": "load",
      "click .add-item": "load",
      "click .edit-item": "edit",
      "click .create": "newlocation"
    },

    newlocation: function(event) {
      event.preventDefault();
      Backbone.Events.trigger("locations:new");
      /* // Create the modal view*/
      var view = new NewlocationView({
        callback: this.addlocation
      });
      $('#modal').html(view.render().el);
      $('#modal').modal();
    },

    edit: function(event) {
      event.preventDefault();
      var id = $(event.currentTarget).data("id");
      Backbone.Events.trigger("edit:location", id);
    },

    addlocation: function(name) {
      this.collection.create({
        name: name
      }, {
        success: this.successCreated,
        error: this.errorCreated
      });
    },

    successCreated: function(model) {
      Backbone.Events.trigger("edit:location", model.id);
    },

    errorCreated: function() {
      alert("error");
    },

    render: function() {
      if (this.collection) {
        var self = this;
        $('#dyn-content').html(this.template({ info: this.collection.toJSON() }));
        $(".collapse").collapse();
      } else {
        this._setCollection();
      }
      return this;
    },

    trash: function(event) {
      var field = $(event.currentTarget);

      var model = this.collection.get(field.data("id"));

      model.trash();
      field.parents('li').fadeOut();
    },
    load: function() {
      //alert("loading");
    }
  });
  return Locations;

});
