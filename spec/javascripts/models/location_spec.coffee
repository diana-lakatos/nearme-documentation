#= require require
#= require config
define ["models/Location"], (Location) ->
  describe "Location model", ->
    describe "when instantiated", ->
      it "should exhibit attributes", ->
        name_value = "San Fransisco"
        locationModel = new Location(name: name_value)
        expect(locationModel.get("name")).toEqual name_value

Teabag.execute
