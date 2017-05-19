var Utils;

Utils = function() {
  function Utils() {}

  /*
   * Opens links marked as external in a new browser window
   */
  Utils.links = function() {
    return $('body').on('click', 'a[rel*="external"]', function(e) {
      e.preventDefault();
      return window.open($(e.target).closest('a').attr('href'));
    });
  };

  /*
   * Simple spam prevention by changing example/at/example.com to proper email string
   */
  Utils.mails = function() {
    return $('a[href^="mailto:"]').each(function(index, el) {
      var mail, replaced;
      mail = el.href.replace('mailto:', '');
      replaced = mail.replace('/at/', '@');
      el.href = 'mailto:' + replaced;
      if (el.innerHTML === mail) {
        return el.innerHTML = replaced;
      }
    });
  };

  /*
   * Extra classes on <html> element helping with styling
   */
  Utils.mobile = function() {
    var classes, ua;
    ua = navigator.userAgent.toLowerCase();
    classes = [];
    if (ua.indexOf('android') > -1) {
      classes.push('android');
    }
    if (
      ua.indexOf('android') > -1 && !(ua.indexOf('chrome') > -1) && !(ua.indexOf('firefox') > -1)
    ) {
      classes.push('native');
    }
    if (ua.indexOf('android') > -1 && ua.indexOf('samsungbrowser') > -1) {
      classes.push('native');
    }
    if (ua.indexOf('iemobile/9.') > -1) {
      classes.push('mie9');
    }
    if (ua.indexOf('iemobile/10.') > -1) {
      classes.push('mie10');
    }
    if (ua.indexOf('iemobile') > -1) {
      $('html').removeClass('no-touch').addClass('mie touch');
    }
    return document.documentElement.className += ' ' + classes.join(' ');
  };

  Utils.initialize = function() {
    this.links();
    this.mails();
    return this.mobile();
  };

  return Utils;
}();

module.exports = Utils;
