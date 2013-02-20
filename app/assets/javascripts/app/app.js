//= require app/router
(function() {

  DNM.Dashboard = function() {
    var router = new DNM.Router();
    Backbone.oldSync = Backbone.sync;
    Backbone.sync = function(method, model, options) {
      var params = _.extend({
        beforeSend: function( xhr ) {
          if (!options.noCSRF) {
            var csrftoken = $('meta[name="csrf-token"]').attr('content');
            if (csrftoken) xhr.setRequestHeader('X-CSRF-Token', csrftoken);
            var authtoken = $('meta[name="auth-token"]').attr('content');
            if (authtoken) xhr.setRequestHeader('Authorization', authtoken);
          }
          model.trigger('sync:start');
        }
      }, options);
      Backbone.oldSync(method, model, params);
    }
    Backbone.Events.on("show:locations", function() {
      router.navigate("locations");
      var appView = new AppView();
      appView.setView('locations');
      appView.render();
    });
    router.locations();
  };
})();
