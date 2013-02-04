define "models/location_spec", ["models/location"], (Location) ->
  describe "Location model", ->
    it "should exhibit attributes", ->
      name_value = "San Fransisco"
      locationModel = new Location(name: name_value)
      expect(locationModel.get("name")).toEqual name_value
