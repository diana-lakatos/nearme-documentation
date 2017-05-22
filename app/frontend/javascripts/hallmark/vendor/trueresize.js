/*!
 * (v) True resize helper (v20150214)
 * Helper for resize event in mobile devices to tell if window width has changed
 */

function trueResize() {
  var x = window.innerWidth ||
    document.documentElement.clientWidth ||
    document.querySelector('body').clientWidth;
  if (window.previousWidth === x) {
    return false;
  }
  window.previousWidth = x;
  return true;
}

module.exports = trueResize;
