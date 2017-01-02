import routes from 'routes';
import xhr from '../toolkit/xhr';

class UiSettings {
  getAll(){
    return xhr(routes['ui_settings/index'].url(), { contentType: 'json' });
  }

  get(key) {
    return xhr(routes['ui_settings/get'].url(key), { contentType: 'json'});
  }

  set(key, value) {
    return xhr(routes['ui_settings/set'].url(), {
      data: { id: key, value: value },
      method: 'patch',
      contentType: 'json'
    });
  }
}

module.exports = new UiSettings();
