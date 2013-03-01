var LocationCollection = Backbone.Collection.extend({
  model: LocationModel,
    url: '/v1/locations/list'
});
