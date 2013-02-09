define "models/location_spec", ["models/location"], (Location) ->
  describe "Location model", ->
    it "should exist", ->
      expect(Location).toBeDefined()

    describe "Attributes", ->
      location = new Location
      it "should have default attributes", ->
        expect(location.attributes.name).toBeDefined()
        expect(location.attributes.description).toBeDefined()
        expect(location.attributes.location_type).toBeDefined()
        expect(location.attributes.email).toBeDefined()
        expect(location.attributes.latitude).toBeDefined()
        expect(location.attributes.longitude).toBeDefined()
        expect(location.attributes.formatted_address).toBeDefined()
        expect(location.attributes.availability_template_id).toBeDefined()

      it "should exhibit attributes", ->
        name_value = "San Fransisco"
        locationModel = new Location(name: name_value)
        expect(locationModel.get("name")).toEqual name_value

      it "should have the correct url", ->
        expect(location.url()).toEqual '/v1/locations'
