$('.truncated-ellipsis').each(function() {
  $(this).click(function() {
    $(this).next('.truncated-text').toggleClass('hidden');
    if ($(this).parents('.accordion').length) {
      $('.accordion').css('height', 'auto');
    }
  });
});
