const defaults = {
  method: 'get',
  contentType: 'html'
};

let csrfToken: string, authToken :string;

function getCSRFToken(): string {
  if (!csrfToken) {
    let el = document.querySelector('meta[name="csrf-token"]');
    if (el) {
      csrfToken = el.getAttribute('content');
    }
  }
  return csrfToken;
}

function getAuthToken(): string {
  if (!authToken) {
    let el = document.querySelector('meta[name="authorization-token"]');
    if (el) {
      authToken = el.getAttribute('content');
    }
  }
  return authToken;
}


function parseResponse(response: Response): Promise<string | { [key: string]: string }> {
  let p: Promise<*>;

  if (response.headers.get('Content-Type').toLowerCase().indexOf('json') > -1) {
    p = response.json();
  }
  else {
    p = response.text();
  }

  if (response.status >= 200 && response.status < 300) {
    return p;
  }

  return p.then((data: mixed)=>{
    var error = new Error(response.statusText);
    error.data = data;
    throw error;
  });
}


function getContentTypeString(contentType: string): string {
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

function parseRequestMethod(options: { method: string, data: FormData | { [key: string]: string } }): { [key: string]: string } {
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

/**
 * Makes xhr request
 * @param {String} url
 * @param {Object} options ex. {contentType: 'application/vnd.api+json', data: JSON.stringify({foo: bar}), method: 'post'}
 * @return {Promise} result
 */
function xhr(url: string, options: { method: string, contentType: string, data: mixed } = {}): Promise<any> {
  options = Object.assign({}, defaults, options);
  options = parseRequestMethod(options);

  let xhrOptions = {
    method: options.method,
    credentials: 'same-origin',
    headers: {
      'Accept': getContentTypeString(options.contentType),
      'Content-Type': getContentTypeString(options.contentType),
      'X-CSRF-Token': getCSRFToken(),

      'X-Requested-With': 'XMLHttpRequest'
    }
  };

  if (getAuthToken()) {
    xhrOptions.headers.UserAuthorization = getAuthToken();
  }


  if (options.data) {
    /* in order to allow setting correct content-type boundry by the client we need to remove content type */
    delete xhrOptions.headers['Content-Type'];

    if (options.data instanceof FormData) {
      xhrOptions.body = options.data;
    } else {
      let data = new FormData();
      for (let prop in options.data) {
        if (options.data.hasOwnProperty(prop)) {
          data.append(prop, options.data[prop]);
        }
      }
      xhrOptions.body = data;
    }
  }

  return new Promise((resolve: Promise, reject: Promise)=>{
    fetch(url, xhrOptions)
            .then(parseResponse)
            .then( (data: any): Promise => resolve(data) )
            .catch((error: any): Promise =>{
              if (error.data) {
                return reject(error.data);
              }
              return reject(error);
            });
  });
}

module.exports = xhr;
