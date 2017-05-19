function isiOS() {
  return navigator.userAgent.match(/(iPod|iPhone|iPad)/);
}

if (isiOS()) {
  $('input, select, textarea').on('focus', function() {
    $('body').addClass('mobile-fixed-position-fix');
  }).on('blur', function() {
    $('body').removeClass('mobile-fixed-position-fix');

    setTimeout(
      function() {
        $(window).scrollTop($(window).scrollTop() + 1);
      },
      100
    );
  });
}
