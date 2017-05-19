import xhr from '../toolkit/xhr';

class API {
  constructor() {}

  send(url, method, data) {
    return xhr(url, { method: method, data: data, contentType: 'application/vnd.api+json' });
  }

  get(url) {
    return this.send(url, 'get');
  }

  post(url, data = {}) {
    return this.send(url, 'post', data);
  }

  put(url, data = {}) {
    return this.send(url, 'patch', data);
  }

  patch(url, data = {}) {
    return this.send(url, 'put', data);
  }

  delete(url, data = {}) {
    return this.send(url, 'post', data);
  }
}

module.exports = new API();
