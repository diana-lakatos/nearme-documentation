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
    templates: 'templates', // path for template files
    modernizr: 'libs/modernizr',
    location_finder: 'components/location_finder',
    search_controller: 'components/controller',
    geocoder: 'components/geocoder',
    google: 'https://maps.googleapis.com/maps/api/js?libraries=places&sensor=false&callback=focus'
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
    },
     'geocoder': {
      deps: ['search_controller', 'google'],
      exports: 'geocoder'
    },
    'location_finder': {
      deps: ['search_controller', 'modernizr', 'geocoder', 'google'],
      exports: "location_finder"
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

