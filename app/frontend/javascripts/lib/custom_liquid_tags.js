// Global handler of liquid select locale tag
$(function() {
  $('select.locales_languages_select').change(function() {
    location.href = $(this).val();
  });
});
