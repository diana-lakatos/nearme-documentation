'use strict';

import NM from 'nm';

require('expose?jQuery|expose?$!jquery');
require('jquery-ujs/src/rails');
require('../vendor/jquery-ui-1.9.2.custom.min');
require('jquery-ui/ui/widget');
require('bootstrap-sass/assets/javascripts/bootstrap');
require('../vendor/nested_form');
require('../vendor/cocoon');

NM.on('ready', ()=>{
  require('initializers/shared/linechart.initializer');
  require('initializers/shared/timeago.initializer');
  require('initializers/shared/modal.initializer');
  require('initializers/shared/ckeditor.initializer');
  require('initializers/shared/colorpicker.initializer');
  require('initializers/shared/icui.initializer');
  require('initializers/shared/fileupload.initializer');
  require('initializers/shared/bootstrap_tooltip.initializer');

  require('initializers/instance_admin/ace_editor.initializer');
  require('initializers/instance_admin/add_new_button.initializer');
  require('initializers/instance_admin/admin_roles.initializer');
  require('initializers/instance_admin/admins.initializer');
  require('initializers/instance_admin/approval_requests.initializer');
  require('initializers/instance_admin/bootstrap_switch.initializer');
  require('initializers/instance_admin/categories.initializer');
  require('initializers/instance_admin/root_categories.initializer');
  require('initializers/instance_admin/chosen.initializer');
  require('initializers/instance_admin/default_images.initializer');
  require('initializers/instance_admin/dimension_templates.initializer');
  require('initializers/instance_admin/faqs.initializer');
  require('initializers/instance_admin/fileupload_filename.initializer');
  require('initializers/instance_admin/form_components.initializer');
  require('initializers/instance_admin/form_submit.initializer');
  require('initializers/instance_admin/forms.initializer');
  require('initializers/instance_admin/help_bar.initializer');
  require('initializers/instance_admin/inline_labels.initializer');
  require('initializers/instance_admin/listings_schedule.initializer');
  require('initializers/instance_admin/locations.initializer');
  require('initializers/instance_admin/pages.initializer');
  require('initializers/instance_admin/panel_tabs.initializer');
  require('initializers/instance_admin/partners.initializer');
  require('initializers/instance_admin/payment_gateway.initializer');
  require('initializers/instance_admin/photo_manipulator.initializer');
  require('initializers/instance_admin/photo_upload_versions.initializer');
  require('initializers/instance_admin/subscription_pricing.initializer');
  require('initializers/instance_admin/popover.initializer');
  require('initializers/instance_admin/preferences_checkbox_slider.initializer');
  require('initializers/instance_admin/search_settings.initializer');
  require('initializers/instance_admin/section_controllers.initializer');
  require('initializers/instance_admin/settings.initializer');
  require('initializers/instance_admin/shipping_profiles.initializer');
  require('initializers/instance_admin/support_assigner.initializer');
  require('initializers/instance_admin/support_ticket_message.initializer');
  require('initializers/instance_admin/tags.initializer');
  require('initializers/instance_admin/theme.initializer');
  require('initializers/instance_admin/wish_list.initializer');
  require('initializers/instance_admin/workflow_form.initializer');
  require('initializers/application/language_switch.initializer');
  require('initializers/instance_admin/cancellation_policies.initializer');
});
