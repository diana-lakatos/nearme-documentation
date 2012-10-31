class @SpaceWizardSpaceForm

  constructor: (@form) ->
    @address = new AddressAutocomplete(@form.find('[data-behavior=address-autocomplete]'))
