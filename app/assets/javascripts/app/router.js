DNM.Router = Backbone.Router.extend({
  routes: {
    'locations': 'locations',
    '*actions': 'defaultAction'
  },
  initialize: function(option) {
    this.route(/^locations\/([0-9]+)$/, 'editLocation');
    Backbone.history.start({
      pushState: true,
      root: "/dashboard/"
    });
  },
  locations: function() {
    Backbone.Events.trigger("show:locations");
  },
  defaultAction: function(actions) {
    this.navigate('/locations',true);
  }
});
