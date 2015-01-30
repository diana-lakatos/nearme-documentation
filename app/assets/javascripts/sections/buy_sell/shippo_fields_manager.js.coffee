class @ShippoFieldsManager
  constructor: ->
    $(document).ready =>
      @toggle_shippo_fields_by_checked_status()
      $("#product_form_shippo_enabled, #boarding_form_product_form_shippo_enabled").click =>
        @toggle_shippo_fields_by_checked_status()
        return
  
      return

  toggle_shippo_fields_by_checked_status: ->
    shippo_fields_element = $(".shippo_required_fields_row")
    shippo_checkbox_element = $("#product_form_shippo_enabled, #boarding_form_product_form_shippo_enabled")
    shipping_profile_fields = $(".row.product_shipping_profile_fields_row")
    if (shippo_checkbox_element.length > 0) and shippo_checkbox_element.is(":checked")
      shippo_fields_element.removeClass "disabled"
      shippo_fields_element.addClass "enabled"
      if shipping_profile_fields.length > 0
        shipping_profile_fields.removeClass "enabled"
        shipping_profile_fields.addClass "disabled"
    else
      shippo_fields_element.removeClass "enabled"
      shippo_fields_element.addClass "disabled"
      if shipping_profile_fields.length > 0
        shipping_profile_fields.removeClass "disabled"
        shipping_profile_fields.addClass "enabled"
    return
