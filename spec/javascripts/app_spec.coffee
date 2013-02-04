define "app_spec", ["app"], (App) ->
  describe "App", ->
    it "should be present", ->
      expect( window.DNM).toBeDefined
