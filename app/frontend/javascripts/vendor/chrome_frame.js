$(function() {
  var fn;
  if (typeof CFInstall !== 'undefined' && CFInstall !== null) {
    fn = function() {
      var link;
      link = $('<a />', {
        href: 'http://google.com/chromeframe',
        target: '_blank'
      }).html('Click here to get a better experience using Google Chrome Frame.');
      return $('.navbar').after(
        $('<div />', {
          class: 'browser-alert chrome-frame'
        }).html(
          '<div class="browser-alert-inner"><p><strong>This site might not look right your browser.</strong> ' +
            link[0].outerHTML +
            '</p></div>'
        )
      );
    };
    return CFInstall.check({
      onmissing: fn,
      preventPrompt: true
    });
  }
});
