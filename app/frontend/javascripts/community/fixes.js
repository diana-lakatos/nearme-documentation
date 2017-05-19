var Fixes;

Fixes = function() {
  function Fixes() {}

  /*
   * rewrites <img> src attributes from *.svg to *.png on browsers with lacking support
   */
  Fixes.svg = function() {
    var endsWithDotSvg, i, imgs, l, results;
    if (!(!Modernizr.svg || document.querySelectorAll('html.android.native').length > 0)) {
      return;
    }
    imgs = document.getElementsByTagName('img');
    endsWithDotSvg = /.*\.svg$/;
    i = 0;
    l = imgs.length;
    results = [];
    while (i !== l) {
      if (imgs[i].src.match(endsWithDotSvg)) {
        imgs[i].src = imgs[i].src.slice(0, -3) + 'png';
      }
      results.push(++i);
    }
    return results;
  };

  Fixes.enhancements = function() {
    /*
     * Add class .last-child to all relevant elements in older browsers
     */
    if (!document.addEventListener) {
      return $('*:last-child').addClass('last-child');
    }
  };

  Fixes.initialize = function() {
    this.svg();
    return this.enhancements();
  };

  return Fixes;
}();

module.exports = Fixes;
