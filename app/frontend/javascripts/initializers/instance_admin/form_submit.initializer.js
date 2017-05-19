$('[data-submit-form]').on('click', function() {
  $($(this).data('form-selector')).each(function() {
    $(this).submit();
  });
});

// Make fa-icon submitting icons submit the form
$('.fa-action-icon-submit').click(function() {
  $(this).closest('form').submit();
});
