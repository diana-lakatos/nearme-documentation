'use strict';

import NM from 'nm';

require('expose?jQuery|expose?$!jquery');
require('jquery-ujs/src/rails');

require('../vendor/jquery-ui-1.10.4.custom.min');
require('jquery-ui/ui/widget');
require('jquery-ui-touch-punch');

require('../vendor/bootstrap');
require('../vendor/bootstrap-modal-fullscreen');
require('../vendor/detect-mobile-browser');
require('../vendor/nested_form');
require('../vendor/cocoon');


$.ajaxSetup({
  'beforeSend': function(xhr) {
    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
  }
});

NM.on('ready', ()=>{

  require('initializers/shared/ckeditor.initializer');
  require('initializers/shared/modal.initializer');
  require('initializers/shared/credit_cards.initializer');
  require('initializers/shared/timeago.initializer');
  require('initializers/shared/colorpicker.initializer');
  require('initializers/shared/icui.initializer');
  require('initializers/shared/fileupload.initializer');
  require('initializers/shared/bootstrap_tooltip.initializer');

  require('initializers/application/address_autocomplete.initializer');
  require('initializers/application/approval_request_attachments.initializer');
  require('initializers/application/auth_token.initializer');
  require('initializers/application/availability_details.initializer');
  require('initializers/application/back_to_search.initializer');
  require('initializers/application/bookings.initializer');
  require('initializers/application/bootstrap_select.initializer');
  require('initializers/application/bootstrap_switch.initializer');
  require('initializers/application/cart.initializer');
  require('initializers/application/categories.initializer');
  require('initializers/application/center_search_box.initializer');
  require('initializers/application/custom_inputs.initializer');
  require('initializers/application/custom_selects.initializer');
  require('initializers/application/delivery.initializer');
  require('initializers/application/edit_user.initializer');
  require('initializers/application/flash.initializer');
  require('initializers/application/footer_push.initializer');
  require('initializers/application/home.initializer');
  require('initializers/application/infinite_scrolling.initializer');
  require('initializers/application/language_switch.initializer');
  require('initializers/application/limiter.initializer');
  require('initializers/application/mobile_fixed_position_fix.initializer');
  require('initializers/application/multiselect.initializer');
  require('initializers/application/payment_documents.initializer');
  require('initializers/application/phone_number_fields.initializer');
  require('initializers/application/registration_forms.initializer');
  require('initializers/application/rel_submit_links.initializer');
  require('initializers/application/flash_messages_links.initializer');
  require('initializers/application/reservation_review.initializer');
  require('initializers/application/reviews.initializer');
  require('initializers/application/route_link.initializer');
  require('initializers/application/save_search.initializer');
  require('initializers/application/search_datepickers.initializer');
  require('initializers/application/search_results.initializer');
  require('initializers/application/seller_attachment_access_level_selector.initializer');
  require('initializers/application/seller_attachments.initializer');
  require('initializers/application/shipping_address.initializer');
  require('initializers/application/social_buttons.initializer');
  require('initializers/application/space.initializer');
  require('initializers/application/space_flow_form.initializer');
  require('initializers/application/support_attachment_form.initializer');
  require('initializers/application/support_faq.initializer');
  require('initializers/application/support_tickets.initializer');
  require('initializers/application/truncated_text.initializer');
  require('initializers/application/user_reviews.initializer');
  require('initializers/application/wish_list_buttons.initializer');
});
