/* Reveal input when user clicks 'add new' */
var hidden = $('.add-new-hidden').hide();

$('.add-new-btn').on('click', function() {
  hidden.slideDown();
});
