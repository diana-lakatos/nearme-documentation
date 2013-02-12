define(['jquery', 'underscore', 'backbone'], function($, _, Backbone) {
  $.ajaxSetup({
    statusCode: {
      401: function() {
        // Redirect the to the login page.
      },
      403: function() {
        // 403 -- Access denied
        // Redirect the to the login page.
      }
    }
  });

  //Define all routes here
  var AppRouter = Backbone.Router.extend({
    routes: {
      // Screens
      'locations': 'locations',
      // Default
      '*actions': 'defaultAction'
    },

    initialize: function(option) {
      this.route(/^locations\/([0-9]+)$/, 'editLocation');
    },

    locations: function() {
      Backbone.Events.trigger("show:locations");
    },

    defaultAction: function(actions) {
     this.navigate('/locations',true);
    }

  });

  var app_router = null;
  var initialize = function(settings) {
      app_router = new AppRouter();
      Backbone.history.start({
        pushState: true,
        root: "/dashboard/"
      });
    };

  var navigate = function(param) {
      app_router.navigate(param);
    };


  return {
    initialize: initialize,
    navigate: navigate
  };
});

