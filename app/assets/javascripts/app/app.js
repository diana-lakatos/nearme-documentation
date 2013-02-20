//= require app/router
(function() {

  DNM.Dashboard = function() {
    var router = new DNM.Router();
    Backbone.Events.on("show:locations", function() {
      router.navigate("locations");
      var appView = new AppView();
      appView.setView('locations');
      appView.render();
    });
    router.locations();
  };
})();
