class @Dashboard.AnalyticsController

  constructor: (@container) ->
    @analyticsModeSelect = @container.find('select.analytics-mode')
    @bindEvents()

  bindEvents: =>
    @analyticsModeSelect.on 'change', =>
      location.href = location.pathname + '?analytics_mode=' + @analyticsModeSelect.val()

