/*define([$,_], function($,_) {*/
  //var App = function() {
  //};

  //App.prototype = {
  //};

  //return App;
/*});*/

define(['views/app'], function(AppView) {
  var App = function() {
    this.views = {};
    this.views.app = new AppView();
    this.views.app.render();
  };
  return App;
});
