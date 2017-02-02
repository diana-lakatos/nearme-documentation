require('../vendor/jquery-tokeninput')

module.exports = class Tags

  constructor: ->
    @tagList = $("input[data-tags]")
    @bindEvents() if @tagList?

  bindEvents: ->
    @initialize()
    @adjustDropdownWidth()
    @preventEnterSubmissionWhileOnInput()

  initialize: ->
    translations = @getTranslations()
    json = JSON.parse(@tagList.attr("data-tags"))

    options = {
      excludeCurrent: true,
      preventDuplicates: true,
      allowFreeTagging: @atInstanceAdmin(),
      prePopulate: json.prepopulate,
      tokenValue: "name",
      hintText: translations.hint,
      noResultsText: @atInstanceAdmin() && translations.no_results.instance_admin || translations.no_results.default,
      searchingText: translations.searching
    }

    @tagList.tokenInput(json.url, options)

  adjustDropdownWidth: ->
    dropdown = $(".token-input-dropdown")
    controls = $(".token-input-list").parent()
    dropdown.width(controls.width())

  preventEnterSubmissionWhileOnInput: ->
    @tagList.on "keypress", (event) ->
      event.preventDefault() if event.keyCode == "13"

  getTranslations: ->
    I18n.t.components.tag_list

  atInstanceAdmin: ->
    window.location.href.match(/instance_admin/)
