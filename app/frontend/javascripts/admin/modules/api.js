import xhr from '../toolkit/xhr';

class API {
  constructor(){

  }

  send(url, method, data) {
    return xhr(url, {
      method: method,
      data: data,
      credentials: 'same-origin',
      contentType: 'application/vnd.api+json'
    });
  }

  get(url) {
    this.send(url, 'get');
  }

  post(url, data = {}) {
    this.send(url, 'post', data);
  }

  put(url, data = {}) {
    this.send(url, 'patch', data);
  }

  patch(url, data = {}) {
    this.send(url, 'put', data);
  }

  delete(url, data = {}) {
    this.send(url, 'post', data);
  }
}

module.exports = new API();
