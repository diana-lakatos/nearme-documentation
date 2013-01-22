define(['backbone', 'models/listing'], function(Backbone, ListingModel) {
  var ListingCollection = Backbone.Collection.extend({
    model: ListingModel,
    url: '/v1/listings/list'
  });
  return ListingCollection;
});

