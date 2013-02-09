define "collections/listing_spec", ["collections/listing", "models/listing"], (ListingCollection, ListingModel) ->
  describe "Listing collection", ->
    listings = new ListingCollection
    it "should exist", ->
      expect(ListingCollection).toBeDefined()

    it "should use the Listing model", ->
      expect(listings.model).toEqual ListingModel

    it "should have the correct url", ->
      expect(listings.url).toEqual '/v1/listings/list'
