define(['backbone','backbone_sync', 'router', 'views/app'], function(Backbone, Sync, AppRouter, AppView) {
  var App = function() {
    Backbone.Sync = Sync;
    Backbone.Events.on("show:locations", function() {
      AppRouter.navigate("locations");
      var appView = new AppView();
      appView.setView('locations');
      appView.render();
    });

    AppRouter.initialize();

  };
  return App;
});
