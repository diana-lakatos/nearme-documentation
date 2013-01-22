define(['backbone', 'models/location'], function(Backbone, LocationModel) {
  var LocationCollection = Backbone.Collection.extend({
    model: LocationModel,
    url: '/v1/locations/list'
  });
  return LocationCollection;
});

