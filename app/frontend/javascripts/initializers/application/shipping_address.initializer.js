var el = $('[data-shipping-country-controller]');
var billingCheck = $('#order_use_billing');
var shippingWrapper = $('#shipping-address');

function toggleShippingAddress() {
  shippingWrapper.toggle(!billingCheck.prop('checked'));
}

function loadStatesForCountry(country_id, url, bill_address) {
  $.get(url, { country_id: country_id, bill_address: bill_address });
}

if (el.length > 0) {
  billingCheck.on('click', function() {
    toggleShippingAddress();
  });

  $('#order_billing_address_attributes_country_id').on('change', function() {
    loadStatesForCountry($(this).val(), $(this).data('get-states-url'), 1);
  });

  $('#order_shipping_address_attributes_address_attributes_country_id').on('change', function() {
    loadStatesForCountry($(this).val(), $(this).data('get-states-url'), 1);
  });

  $('#order_shipping_address_attributes_country_id').on('change', function() {
    loadStatesForCountry($(this).val(), $(this).data('get-states-url'), 0);
  });

  $('#order_shipping_address_attributes_country_id').on('change', function() {
    loadStatesForCountry($(this).val(), $(this).data('get-states-url'), 0);
  });

  toggleShippingAddress();
}
