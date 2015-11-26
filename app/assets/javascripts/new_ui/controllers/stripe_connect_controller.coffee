class @DNM.StripeConnectController

  constructor: (@container) ->
    @accountTypeSelect = @container.find("select[data-account-type]")
    @bindEvents()
    @accountTypeSelect.change()

  bindEvents: ->
    @accountTypeSelect.on 'change', ->
      companyFields = $("div[data-account-type=company]")
      if $(@).val() == 'company'
        companyFields.removeClass('hidden')
      else
        companyFields.addClass('hidden')


$('form[data-payouts-form]').each (index, item) =>
  new DNM.StripeConnectController($(item))
