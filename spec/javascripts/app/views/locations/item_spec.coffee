define "views/locations/item_spec", ["collections/listing", "models/location", "views/locations/item"], (ListingCollection, LocationModel, LocationView) ->
  describe "Location view", ->
    new_location_data = getJSONFixture('new_location.json')

    listings_data = [
      {
        id: 1
        name: 'Board Room'
      },
      {
        id: 2
        name: 'Conference Room'
      },
      {
        id: 3
        name: 'Open Space'
      }
    ]
    location_data ={ id: 1, name: 'San Francisco', listings: listings_data}
    hook_element = document.createElement 'div'
    $hook = $(hook_element)
    
    getChildren = (ref)->
      $hook.find(ref.locationView._childContainer).children()
    
    beforeEach ->
      @server = sinon.fakeServer.create()
      @listingCollection = new ListingCollection listings_data
      @locationView = new LocationView
        collection: @listingCollection
        model: new LocationModel(location_data)
        el: hook_element

      @locationView.render()

    afterEach ->
      @locationView.remove()
      @server.restore()

    it "should be defined", ->
      expect(LocationView).toBeDefined()

    it "should have a hook element", ->
      expect(@locationView.$el).toEqual $hook

    it "should have a collection", ->
      expect(@locationView.collection).toEqual @listingCollection

    it "should render the view when initialized", ->
      expect(getChildren(@).length).toEqual 3

    it "should add a listing when 'add listing' button is clicked", ->
      $addTrigger = $(@locationView._addTrigger, $hook)
      $addTrigger.trigger 'click'
      expect(getChildren(@).length).toEqual 4

    it "should call model.trash when 'Delete this location' button is clicked and confirm is true", ->
      spyOn(window, 'confirm').andReturn(true)
      spyOn(@locationView.model, 'trash')
      $deleteTrigger = $(@locationView._deleteTrigger, $hook)
      $deleteTrigger.trigger 'click'
      expect(@locationView.model.trash).toHaveBeenCalled()

    it "should not call model.trash when 'Delete this location' button is clicked and confirm is false", ->
      spyOn(window, 'confirm').andReturn(false)
      spyOn(@locationView.model, 'trash')
      $deleteTrigger = $(@locationView._deleteTrigger, $hook)
      $deleteTrigger.trigger 'click'
      expect(@locationView.model.trash).not.toHaveBeenCalled()

    it "should send an ajax request to save the location", ->
       @locationView.model = new LocationModel(new_location_data)
       spyOn(@locationView, '_serializeData').andReturn new_location_data
       e = $.Event("click")
       @locationView.save(e)
       expect(@server.requests.length).toEqual 1
       expect(@server.requests[0].method).toEqual('POST')
       expect(@server.requests[0].requestBody).toEqual JSON.stringify(new_location_data)

     it "should send an ajax request to update the location", ->
       spyOn(@locationView, '_serializeData').andReturn location_data
       e = $.Event("click")
       @locationView.save(e)
       expect(@server.requests.length).toEqual 1
       expect(@server.requests[0].method).toEqual('PUT')
       expect(@server.requests[0].requestBody).toEqual JSON.stringify(location_data)

     it "should send an ajax request to delete the location", ->
       spyOn(window, 'confirm').andReturn(true)
       e = $.Event("click")
       @locationView.trash(e)
       expect(@server.requests.length).toEqual 1
       expect(@server.requests[0].method).toEqual('DELETE')
       expect(@server.requests[0].url).toEqual('/v1/locations/1')
