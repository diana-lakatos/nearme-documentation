var SupportFaq;

SupportFaq = function() {
  function SupportFaq(container) {
    this.container = container;
    $('.question', this.container).on('click', function() {
      $(this).parent().toggleClass('opened');
      return $(this).parent().toggleClass('closed');
    });
  }

  return SupportFaq;
}();

module.exports = SupportFaq;
