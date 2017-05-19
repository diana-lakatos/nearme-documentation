var PaymentDocumentsController;

PaymentDocumentsController = function() {
  function PaymentDocumentsController(el) {
    this.container = $(el);
    this.bindEvents();
  }

  PaymentDocumentsController.prototype.bindEvents = function() {
    this.container.find('[data-upload-document]').on('click', function() {
      return $(this).closest('[data-upload]').find('input[type=file]').click();
    });
    return this.container.find('input[type=file]').on('change', function() {
      var fileName, span;
      span = $(this).closest('[data-upload]').find('[data-file-name]');
      fileName = $(this).val().split(/(\\|\/)/g).pop();
      return span.html(fileName);
    });
  };

  return PaymentDocumentsController;
}();

module.exports = PaymentDocumentsController;
