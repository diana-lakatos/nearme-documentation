define "views/listings/item_spec", ["models/listing", "views/listings/item"], (ListingModel, ListingView) ->
  describe "Listing view", ->
    new_listing_data = { name: 'Board Room' }
    listing_data = { id: 1, name: 'Board Room' }

    hook_element = document.createElement 'div'
    $hook = $(hook_element)

    beforeEach ->
      @server = sinon.fakeServer.create()
      @listingView = new ListingView
        model: new ListingModel(listing_data)
        el: hook_element

      @listingView.render()

    afterEach ->
      @listingView.remove()
      @server.restore()

    it "should be defined", ->
      expect(ListingView).toBeDefined()

    it "should have a hook element", ->
      expect(@listingView.$el).toEqual $hook
    
    it "should call model.trash when 'Delete this listing' button is clicked and confirm is true", ->
      spyOn(window, 'confirm').andReturn(true)
      spyOn(@listingView.model, 'trash')
      $deleteTrigger = $(@listingView._deleteTrigger, $hook)
      $deleteTrigger.trigger 'click'
      expect(@listingView.model.trash).toHaveBeenCalled()

    it "should not call model.trash when 'Delete this listing' button is clicked and confirm is false", ->
      spyOn(window, 'confirm').andReturn(false)
      spyOn(@listingView.model, 'trash')
      $deleteTrigger = $(@listingView._deleteTrigger, $hook)
      $deleteTrigger.trigger 'click'
      expect(@listingView.model.trash).not.toHaveBeenCalled()

     it "should send an ajax request to save the listing", ->
       @listingView.model = new ListingModel(new_listing_data)
       spyOn(@listingView, '_serializeData').andReturn new_listing_data
       e = $.Event("click")
       @listingView.save(e)
       expect(@server.requests.length).toEqual 1
       expect(@server.requests[0].method).toEqual('POST')
       expect(@server.requests[0].requestBody).toEqual JSON.stringify(new_listing_data)

     it "should send an ajax request to update the listing", ->
       spyOn(@listingView, '_serializeData').andReturn listing_data
       e = $.Event("click")
       @listingView.save(e)
       expect(@server.requests.length).toEqual 1
       expect(@server.requests[0].method).toEqual('PUT')
       expect(@server.requests[0].requestBody).toEqual JSON.stringify(listing_data)

     it "should send an ajax request to delete the listing", ->
       spyOn(window, 'confirm').andReturn(true)
       e = $.Event("click")
       @listingView.trash(e)
       expect(@server.requests.length).toEqual 1
       expect(@server.requests[0].method).toEqual('DELETE')
       expect(@server.requests[0].url).toEqual('/v1/listings/1')
