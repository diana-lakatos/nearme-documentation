class @InstanceAdmin.ProjectsController

  constructor: (@container) ->
    @container.find('a[data-download-report]').on 'click', (e) ->
      formParameters = $(@).closest('form').serialize()
      reportUrl = $(@).data('report-url')
      location.href = reportUrl + '?' + formParameters
      e.preventDefault()

