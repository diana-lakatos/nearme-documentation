module.exports = class DashboardAnalyticsController

  constructor: (@container) ->
    @analyticsModeSelect = @container.find('select.analytics-mode')
    @start_value = @analyticsModeSelect.val()
    @bindEvents()

  bindEvents: =>
    @analyticsModeSelect.on 'change', =>
      # without this there is infinite redirction on page load
      if @start_value == @analyticsModeSelect.val()
        @start_value = null
      else
        location.href = location.pathname + '?analytics_mode=' + @analyticsModeSelect.val()

