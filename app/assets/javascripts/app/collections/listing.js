ListingCollection = Backbone.Collection.extend({
  model: ListingModel,
    url: '/v1/listings/list'
});
