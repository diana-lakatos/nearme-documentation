define "views/locations/list_spec", ["collections/location", "models/location", "views/locations/list"], (LocationCollection, LocationModel, LocationListView) ->
  describe "Location list view", ->
    locations_data = [
      {
        id: 0
        name: 'San Fransisco'
      },
      {
        id: 1
        name: 'New York'
      },
      {
        id: 2
        name: 'Paris'
      }
    ]
    hook_element = document.createElement 'div'
    $hook = $(hook_element)
    
    getChildren = (ref)->
      $hook.find(ref.locationListView._childContainer).children()
    
    beforeEach ->
      @server = sinon.fakeServer.create()
      @locationCollection = new LocationCollection locations_data
      @locationListView = new LocationListView
        collection: @locationCollection
        el: hook_element

    afterEach ->
      @locationListView.remove()
      @server.restore()

    it "should be defined", ->
      expect(LocationListView).toBeDefined()

    it "should have a hook element", ->
      expect(@locationListView.$el).toEqual $hook

    it "should have a collection", ->
      expect(@locationListView.collection).toEqual @locationCollection

    it "should render the view when initialized", ->
      @locationListView.render()
      expect(getChildren(@).length).toEqual 3

    it "should add a location when 'add location' button is clicked", ->
      $addTrigger = $(@locationListView._addTrigger, $hook)
      $addTrigger.trigger 'click'
      expect(getChildren(@).length).toEqual 4


