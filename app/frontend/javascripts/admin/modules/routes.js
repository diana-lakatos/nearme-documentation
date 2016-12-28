module.exports = {
  'ui_settings/index': {
    url: () => '/admin/ui_settings',
    method: 'get'
  },
  'ui_settings/get': {
    url: (id) => `/admin/ui_settings/get/${id}`,
    method: 'get'
  },
  'ui_settings/set': {
    url: () => '/admin/ui_settings',
    method: 'post'
  },

  'help_contents/show': {
    url: (id) => `/admin/help_contents/${id}`,
    method: 'get'
  },
  'help_contents/update': {
    url: (id) => `/admin/help_contents/${id}`,
    method: 'patch'
  }
};
