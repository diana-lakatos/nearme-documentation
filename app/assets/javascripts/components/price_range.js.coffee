class @PriceRange
  constructor: (element, max, parent) ->
    @element = $(element)
    @parent = parent
    @max = max

    values = @element.find('input').map (k, el) -> el['value']

    @element.find('.slider').slider(
      range: true, values: [values[0], values[1]], min  : 0, max  : @max, step : 25,
      slide: (event, ui) => @onChange(ui.values)
    )

    @updateValue(values[0], values[1])

  updateValue: (min,max) ->
    if parseInt(max) == @max
      max = "#{@max}+"
    @element.find(".value").text("$#{min} - $#{max}/day")

  onChange: (values) ->
    @element.find("input[name*=min]").val(values[0])
    @element.find("input[name*=max]").val(values[1])
    @updateValue(values[0], values[1])
    @parent.fieldChanged('priceRange', values)
