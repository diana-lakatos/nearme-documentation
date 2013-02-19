//= require app/router
(function() {

  router = new AppRouter();
  window.App = function() {
    Backbone.Events.on("show:locations", function() {
      router.navigate("locations");
      var appView = new AppView();
      appView.setView('locations');
      appView.render();
    });

  };
})();
