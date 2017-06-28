/* @flow */
/*
Browsers group style changes and display them in one frame whenever possible.
When using requestAnimationFrame from event handler animation repaint will happen in the same frame
To queue animation to next frame you have to rAF within another rAF call
https://medium.com/@paul_irish/requestanimationframe-scheduling-for-nerds-9c57f7438ef4

This is useful when you want to for example cancel transition and the set it again once changes have been applied
*/
module.exports.requestNextAnimationFrame = function(callback: () => void) {
  window.requestAnimationFrame(function() {
    window.requestAnimationFrame(function() {
      callback();
    });
  });
};
