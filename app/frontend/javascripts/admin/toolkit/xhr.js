const defaults = {
  method: 'get',
  contentType: 'html'
};

let csrfToken, authToken;

function getCSRFToken(){
  if (!csrfToken) {
    csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  }
  return csrfToken;
}

function getAuthToken(){
  if (!authToken) {
    authToken = document.querySelector('meta[name="authorization-token"]').content;
  }
  return authToken;
}


function parseResponse(response) {
  let p;

  if (response.headers.get('Content-Type').toLowerCase().indexOf('json') > -1) {
    p = response.json();
  }
  else {
    p = response.text();
  }

  if (response.status >= 200 && response.status < 300) {
    return p;
  }

  return p.then((data)=>{
    var error = new Error(response.statusText);
    error.data = data;
    throw error;
  });
}


function getContentTypeString(contentType) {
  switch(contentType.toLowerCase()) {

  case 'html':
    return 'text/html';

  case 'text':
    return 'text/plain';

  case 'json':
    return 'application/json';

  default:
    return contentType;
  }
}

function parseRequestMethod(options) {
  options.method = options.method.toLowerCase();
  if (['get', 'post'].indexOf(options.method) > -1) {
    return options;
  }
  options.data = options.data || new FormData();

  if (options.data instanceof FormData) {
    options.data.append('_method', options.method);
  }
  else if (options.data instanceof Object){
    let data = new FormData();
    data.append('_method', options.method);
    for (let key in options.data) {
      if (options.data.hasOwnProperty(key)) {
        data.append(key, options.data[key]);
      }
    }
    options.data = data;
  }
  else {
    throw new Error('Provide data options as either FormData or object literal');
  }
  options.method = 'post';

  return options;
}

function xhr(url, options = {}) {
  options = Object.assign({}, defaults, options);
  options = parseRequestMethod(options);

  let xhrOptions = {
    method: options.method,
    credentials: 'same-origin',
    headers: {
      'Accept': getContentTypeString(options.contentType),
      'Content-Type': getContentTypeString(options.contentType),
      'X-CSRF-Token': getCSRFToken(),
      'UserAuthorization': getAuthToken(),
      'X-Requested-With': 'XMLHttpRequest'
    }
  };

  if (options.data) {
    xhrOptions.body = options.data;
  }

  return new Promise((resolve, reject)=>{
    fetch(url, xhrOptions)
            .then(parseResponse)
            .then( data => resolve(data) )
            .catch((error)=>{
              if (error.data) {
                return reject(error.data);
              }
              return reject(error);
            });
  });
}

module.exports = xhr;
