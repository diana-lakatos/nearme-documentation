var urlUtil = require('../../lib/utils/url');

if (document.getElementById('infinite-scrolling')) {
  $(window).on('scroll.nearme', function() {
    var next_page_path = $('.pagination .next_page').attr('href');
    if (next_page_path && $(window).scrollTop() > $(document).height() - $(window).height() - 60) {
      $(
        '.pagination'
      ).html('<img id="spinner" src="' + urlUtil.assetUrl('spinner.gif') + '" alt="Loading ..." title="Loading ..." />');
      $.getScript(next_page_path);
    }
  });
}
