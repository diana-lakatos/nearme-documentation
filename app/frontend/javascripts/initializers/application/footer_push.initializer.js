var
  wrapper = $('.footer-wrapper'),
  pusher = $('.footer-push');

if (wrapper.length > 0 && pusher.length > 0) {
  pusher.height(wrapper.outerHeight());

  $(window).resize(function(){
    pusher.height(wrapper.outerHeight());
  });
}



