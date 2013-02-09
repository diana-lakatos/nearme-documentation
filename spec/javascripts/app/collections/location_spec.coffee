define "collections/location_spec", ["collections/location", "models/location"], (LocationCollection, LocationModel) ->
  describe "Location collection", ->
    locations = new LocationCollection
    it "should exist", ->
      expect(LocationCollection).toBeDefined()

    it "should use the Location model", ->
      expect(locations.model).toEqual LocationModel

    it "should have the correct url", ->
      expect(locations.url).toEqual '/v1/locations/list'
