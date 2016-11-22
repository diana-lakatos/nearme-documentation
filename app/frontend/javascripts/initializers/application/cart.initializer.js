var form = $('#cart');
form.find('select[name^=quantity]').on('change', function() {
  form.submit();
});
