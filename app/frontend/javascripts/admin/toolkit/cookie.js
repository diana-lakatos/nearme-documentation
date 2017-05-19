export function readCookie(name) {
  let cookies = {};
  document.cookie.split('; ').forEach(c => {
    let [ n, v ] = c.split('=');
    cookies[n] = v;
  });

  return cookies[name];
}

export function setCookie(name, value, days) {
  var expires = '';
  if (days) {
    var date = new Date();
    date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
    expires = `; expires=${date.toGMTString()}`;
  }

  document.cookie = `${name}=${value}${expires}; path=/`;
}
