// @flow
type LocationType = {
  href: string,
  protocol: string,
  host: string,
  hostname: string,
  port: string,
  pathname: string,
  search: string,
  hash: string
};

module.exports.parseUrl = function(href: string): ?LocationType {
  let match = href.match(
    /^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)([\/]{0,1}[^?#]*)(\?[^#]*|)(#.*|)$/
  );
  if (!match) {
    return;
  }
  return {
    href: href,
    protocol: match[1],
    host: match[2],
    hostname: match[3],
    port: match[4],
    pathname: match[5],
    search: match[6],
    hash: match[7]
  };
};

module.exports.jsonp = function(uri: string): Promise<*> {
  return new Promise(function(resolve, reject) {
    let id = '_' + Math.round(10000 * Math.random());
    let callbackName = `jsonp_callback_${id}`;
    window[callbackName] = function(data) {
      delete window[callbackName];
      let ele = document.getElementById(id);
      if (ele instanceof HTMLElement && ele.parentElement) {
        ele.parentElement.removeChild(ele);
      }
      resolve(data);
    };

    let conjunction = uri.indexOf('?') > -1 ? '&' : '?';
    let src = `${uri}${conjunction}callback=${callbackName}`;
    let script = document.createElement('script');
    script.src = src;
    script.id = id;
    script.addEventListener('error', reject);

    let head = document.querySelector('head');
    if (!head) {
      throw new Error('Invalid context, must be executed in browser');
    }
    head.appendChild(script);
  });
};
