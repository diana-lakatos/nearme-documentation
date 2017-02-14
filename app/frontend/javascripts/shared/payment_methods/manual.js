const Loader = require('./modules/loader');

class PaymentMethodManual {

  constructor() {
    this.form = $('#checkout-form, #new_payment');
    this._submitFormHandler();
  }

  _submitFormHandler() {
    var $form = $(this.form),
      that = this;

    $form.unbind('submit').submit(function() {
      that._submitCheckoutForm.call(that);
    });
  }

  _submitCheckoutForm() {
    var $form = $('#checkout-form, #new_payment'),
      that = this;

    // Send form via ajax if its in a modalbox (ie. when accepting offer in UOT)
    if ($form.parents('.dialog__content').length > 0) {
      console.log('PaymentMethodManual :: Form submitted. Submitting checkout form using AJAX. Data: ', $form.serialize());

      $.ajax({
        url: $form.attr('action'),
        method: 'POST',
        dataType: 'json',
        data: $form.serialize()
      })
      .done(that._successResponse)
      .always(Loader.hide);

    } else {
      console.log('PaymentMethodManual :: Submitting checkout form.');

      // Submit form while going through standard checkout process
      $form.get(0).submit();
    }
  }

  _successResponse(response) {
    var $form = $('#checkout-form, #new_payment');
    if (response.saved || response.redirect) {
      const redirectUrl = $form.attr('data-redirect-to') || response.redirect;
      if (redirectUrl) {
        console.log('PaymentMethodManual :: Form submitted. Redirecting to ', redirectUrl);
        window.location.replace(redirectUrl);
      } else {
        console.log('PaymentMethodManual :: Form submitted. Reloading...');
        window.location.reload();
      }
    } else {
      console.log('PaymentMethodManual :: Form submitted. Updating content');
      $('.dialog__content').html(response.html);
    }
  }

}
module.exports = PaymentMethodManual;
