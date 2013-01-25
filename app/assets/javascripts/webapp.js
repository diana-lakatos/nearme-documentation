requirejs.config({
  baseUrl: '/assets/app',

  paths: {
    jquery: 'libs/jquery/jquery',
    underscore: 'libs/underscore',
    json: 'libs/json',
    backbone: 'libs/backbone/backbone',
    backbone_sync: 'libs/backbone/backbone.sync.rails',
    bootstrap: 'libs/bootstrap',
    handlebars: 'libs/handlebars/handlebars',
    i18nprecompile: 'libs/handlebars/i18nprecompile',
    hbs: 'libs/handlebars/hbs',
    text: 'libs/require/text', // required plugin to load non js file
    templates: 'templates' // path for template files
  },

  shim: {
    'underscore': {
      exports: '_'
    },
    'backbone': {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    },
    'backbone_sync': {
      deps: ["jquery", "backbone"],
      exports: "backbone_sync"
    }
  },

  hbs: {
    deps: ['underscore'],
    templateExtension: 'hbs',
    // if disableI18n is `true` it won't load locales and the i18n helper
    // won't work as well.
    disableI18n: false
  }

});

require(['app'], function(App) {
  window.DNMAPP = new App();
});

