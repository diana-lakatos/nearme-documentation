class @Accordian

  @initialize: (scope = $('body')) ->
    # Observe clicks on the expand/collapse nodes of accordians
    scope.on 'click', '.accordian > li > a > i', (event) =>
      @toggleAccordian $(event.target).closest('li')
      event.preventDefault()

  @toggleAccordian: (target) ->
    target.toggleClass('expanded')

