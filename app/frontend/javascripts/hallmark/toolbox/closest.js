function closest(el, selector, includeSelf = true) {
  let matchesFn, parent;

  /* find vendor prefix */
  ['matches','webkitMatchesSelector','mozMatchesSelector','msMatchesSelector','oMatchesSelector'].some(function(fn) {
    if (typeof document.body[fn] == 'function') {
      matchesFn = fn;
      return true;
    }
    return false;
  });

  if (includeSelf && el[matchesFn](selector)) {
    return el;
  }

  /* traverse parents */
  while (el) {
    parent = el.parentElement;
    if (parent && parent[matchesFn](selector)) {
      return parent;
    }
    el = parent;
  }

  return null;
}

module.exports = closest;
