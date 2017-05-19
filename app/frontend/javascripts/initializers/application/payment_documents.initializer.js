var els = $('#checkout-form .document-requirements');
if (els.length > 0) {
  require.ensure('../../sections/checkout/payment_documents_controller', function(require) {
    var PaymentDocumentsController = require(
      '../../sections/checkout/payment_documents_controller'
    );
    return new PaymentDocumentsController(els);
  });
}
