//= require jquery
//= require jquery_ujs
//= require ./vendor/jquery-ui-1.9.2.custom.min
//= require ./vendor/jQueryRotate
//= require ./instance_admin/bootstrap
//= require ./instance_admin/bootstrap-select
//= require ./vendor/modernizr
//= require ./vendor/Chart
//= require components/chart_wrapper
//= require bootstrap-switch
//= require components/photo
//= require components/ckfile
//= require jquery-fileupload/basic
//= require components/fileupload
//= require components/modal
//= require components/tags
//= require jcrop
//= require select2
//= require advanced_closest
//= require sections/search_instance_admin
//= require javascript_module
//= require ./instance_admin/searchable_admin_resource
//= require ./instance_admin/searchable_admin_service
//= require dimensions_templates_admin_behaviors
//= require_tree ./instance_admin/sections
//= require jquery_nested_form
//= require ./vendor/urlify
//= require ./vendor/icui
//= require ./vendor/strftime
//= require ./vendor/jquery.tokeninput
//= require ./blog/admin/blog_posts_form
//= require lib/timeago.jquery
//= require ckeditor/basepath
//= require ckeditor/init
//= require lib/timeago.jquery
//= require ./instance_admin/jquery.jstree
//= require components/ace_editor_textarea_binding
//= require sections/support
//= require sections/support/attachment_form
//= require sections/support/ticket_message_controller
//= require sections/dashboard/shipping_profiles
//= require ./instance_admin/script
//= require chosen-jquery
//= require instance_admin/jquery-ui-datepicker
//= require instance_admin/data_tables/jquery.dataTables.min
//= require instance_admin/data_tables/dataTables.bootstrap
//= require instance_admin/bootstrap-colorpicker.js
// NEW UI LIBS

// Date picker
//= require moment/min/moment.min
//= require eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker

// Cocoon for nested forms
//= require cocoon

//= require new_ui/index
//= require new_ui/instance_admin/index
//= require new_ui/listings/schedule

$(function() {
  Fileupload.initialize();
})

$('[rel=tooltip]').tooltip();

$('select.chosen').chosen();

$("input.bootstrap_switch").bootstrapSwitch();

// Graceful degradation for missing inline_labels
// Make the original label visible
$('.control-group.boolean .controls label.checkbox').each(function() {
  try {
    var text = $(this).html();
    if(text.match(/^\s*<[^<>]+>\s*$/)) {
      $(this).parents('.control-group.boolean').find('label.boolean.control-label').show();
    }
  } catch(e) {
    // Avoid graceful degradation code from impacting page
    // errors, if present are not treated
  }
});

// Make fa-icon submitting icons submit the form
$('.fa-action-icon-submit').click(function() {
  $(this).closest('form').submit();
});

