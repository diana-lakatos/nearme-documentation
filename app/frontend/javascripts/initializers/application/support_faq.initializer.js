var els = $('#support-faq');
if (els.length > 0) {
  require.ensure('../../sections/support_faq', function(require) {
    var SupportFaq = require('../../sections/support_faq');
    return new SupportFaq(els);
  });
}
