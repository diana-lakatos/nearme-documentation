var Modal = require('../../components/modal');
Modal.listen();

$(document).on('close:modal.nearme', function(){
  Modal.close();
});

$(document).on('load:modal.nearme', function(event, url){
  Modal.load(url);
});

$(document).on('setclass:modal.nearme', function(event, klass){
  Modal.setClass(klass);
});

/* initializeModalClose */
/* Re-enable form submit buttons on sign-in/sign-up modal close */
$(document).on('click.nearme', '.sign-up-modal a.modal-close, .modal-overlay', function() {
  var need_reenable = $('.triggers-show-modal');
  if(need_reenable.length > 0) {
    $.rails.enableFormElements(need_reenable);
  }
});

/* initializeModalClose */
/* Re-enable form submit buttons on sign-in/sign-up modal close */
$(document).on('click.nearme', '.sign-up-modal a.modal-close', function() {
  var reservation_request_form = $('form.reservation_request');
  if(reservation_request_form.length > 0) {
    $.rails.enableFormElements(reservation_request_form);
    reservation_request_form.find('[data-behavior=reviewBooking]').removeClass('click-disabled');
  }
});

$(document).on('init:modalform.nearme', function(event, context){
  require.ensure('../../components/modal_form', function(require){
    var ModalForm = require('../../components/modal_form');
    return new ModalForm($(context));
  });
});

$( document ).on('modal-shown.nearme', function(e, containerElement) {
  $(containerElement).find('input[data-authenticity-token]').val($('meta[name="authenticity_token"]').attr('content'));
});
