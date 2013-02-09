#describe "PriceRange", ->
  #beforeEach ->
    #affix('.price-range input[name=price-min] input[name=price-max] .slider .value')
    #$('input[name*=min]').val(0)
    #$('input[name*=max]').val(300)
    #@parent = jasmine.createSpyObj('Form', ['fieldChanged'])
    #@priceRange = new PriceRange('.price-range', 300, @parent)
    #spyOn(@priceRange, 'updateValue').andCallThrough();

  #describe '#constructor', ->
    #it "updates the values", ->
      #expect($('.value').text()).toMatch(/300\+/)

  #describe '#updateValue', ->
    #context "when max is the price ceiling", ->
      #it "appends a +", ->
        #@priceRange.updateValue(0,300)
        #expect($('.value').text()).toMatch(/300\+/)
    #context "when max is below the price ceiling", ->
      #it "does not append a +", ->
        #@priceRange.updateValue(0,200)
        #expect($('.value').text()).toMatch(/200\//)


  #describe "#onChange", ->
    #beforeEach ->
      #@priceRange.onChange([0,300])
    #it "Tells its parent it was changed", ->
      #expect(@parent.fieldChanged).toHaveBeenCalledWith('priceRange', [0,300])
    #it "Updates its values", ->
      #expect(@priceRange.updateValue).toHaveBeenCalledWith(0,300)
      #expect($('input[name*=min]').val()).toEqual('0')
      #expect($('input[name*=max]').val()).toEqual('300')


