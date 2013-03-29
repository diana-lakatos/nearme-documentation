$ ->
  if CFInstall?
    fn = ->
      link = $('<a />', { href: '//google.com/chromeframe', target: '_blank' }).html('Click here to get a better experience using Google Chrome Frame.');
      $('.navbar').after($('<div />', { class: 'browser-alert chrome-frame' }).html("<div class=\"browser-alert-inner\"><p><strong>This site might not work properly on your browser.</strong> #{link[0].outerHTML}</p></div>"))
    
    CFInstall.check({ onmissing: fn, preventPrompt: true });