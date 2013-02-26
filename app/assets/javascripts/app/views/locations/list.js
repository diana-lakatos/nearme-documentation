LocationsView = Backbone.View.extend({
  el: '#dyn-content',
  template: HandlebarsTemplates['app/templates/locations/list'],
  initialize: function() {
    _.bindAll(this, 'render', 'addAll', 'addOne', 'createLocation');
    this._childContainer = '.locations-area';
    this._addTrigger = '.add-location';
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

  createLocation: function(event) {
    event.preventDefault();
    event.stopPropagation();
    var locationModel = new LocationModel();
    this.addOne(locationModel);
  },

  addAll: function() {
    this.collection.each(this.addOne);
  },

  addOne: function(locationModel) {
    var view = new LocationView({ model: locationModel });
    var content = view.render().el;
    $(this.$el).find(this._childContainer).append(content);
    if (locationModel.isNew()) {
      $(".location-content", $(content)).collapse('show'); // expend the location container
      $("input#name", $(content)).focus();
    }
  },

  render: function() {
    if (this.collection) {
      this.$el.html(this.template());
      this.addAll();
      $(".collapse").collapse({toggle: false});
    } else {
      this._setCollection();
    }
    return this;
  }

});
