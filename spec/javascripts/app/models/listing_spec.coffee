define "models/listing_spec", ["models/listing"], (Listing) ->
  describe "listing model", ->
    it "should exist", ->
      expect(Listing).toBeDefined()

    describe "Attributes", ->
      listing = new Listing()
      it "should have default attributes", ->
        expect(listing.attributes.location_id).toBeDefined()
        expect(listing.attributes.name).toBeDefined()
        expect(listing.attributes.description).toBeDefined()
        expect(listing.attributes.listing_type_id).toBeDefined()
        expect(listing.attributes.quantity).toBeDefined()
        expect(listing.attributes.defer_availability_rules).toBeDefined()
        expect(listing.attributes.availability_template_id).toBeDefined()

      it "should exhibit attributes", ->
        name_value = "Board Room"
        listingModel = new Listing(name: name_value)
        expect(listingModel.get("name")).toEqual name_value

      it "should have the correct url", ->
        expect(listing.url()).toEqual '/v1/listings'
