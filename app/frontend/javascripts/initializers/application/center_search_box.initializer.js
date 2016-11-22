function centerSearchBox(){
  var
    navbar_height = $('.navbar-fixed-top').height(),
    image_height = $('.dnm-page').height(),
    search_height = $('#search_row').height(),
    wood_box_height = $('.wood-box').height();
  $('#search_row').css('margin-top', (image_height)/2 - search_height/2 + navbar_height/2 - wood_box_height/2 + 'px');
}

if (document.querySelector('.main-page')) {
  $(window).on('resize.nearme', centerSearchBox);
  centerSearchBox();
}



