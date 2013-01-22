define(['backbone'], function(Backbone) {
  var ListingModel = Backbone.Model.extend({
    initialize: function(attributes) {},

    url: function() {
      var base = '/v1/locatings';
      if (this.isNew()) {
        return base;
      }
      return base + (base.charAt(base.length - 1) == '/' ? '' : '/') + this.id;
    }
  });
  return ListingModel;
});

