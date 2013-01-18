requirejs.config({
  baseUrl:'/assets/app',

  paths: {
    jquery:'libs/jquery/jquery',
    underscore:'libs/underscore',
    json:'libs/json',
    backbone:'libs/backbone',
    handlebars:'libs/handlebars/handlebars',
    i18nprecompile:'libs/handlebars/i18nprecompile',
    hbs:'libs/handlebars/hbs',
    text:'libs/require/text', // required plugin to load non js file
    templates: 'templates' // path for template files
  },

  shim: {
    'underscore': {
      exports: '_'
    },
    'backbone': {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    }
  },

  hbs : {
    deps: ['underscore'],
    templateExtension : 'hbs',
    // if disableI18n is `true` it won't load locales and the i18n helper
    // won't work as well.
    disableI18n : false
  }

});

/*require.config({*/
  //baseUrl:'/assets/app',
  //paths:{
          //jquery:'../libs/jquery/jquery',
          //jqueryui:'../libs/jquery/jquery-ui-1.8.17.custom',
          //jquerycookie:'../libs/jquery/jquery.cookie',
          //underscore:'../libs/underscore',
          //json:'../libs/json',
          //backbone:'../libs/backbone/backbone',
          //marionette:'../libs/backbone/backbone.marionette',
          //ext_marionette:'../libs/backbone/ext-marionette',
          //backbone_sync:'../libs/backbone/backbone.sync.rails',
          //wishbone:'../libs/backbone/wishbone',
          //modelbinder:'../libs/backbone/backbone.ModelBinder',
          //handlebars:'../libs/handlebars/handlebars',
          //i18nprecompile:'../libs/handlebars/i18nprecompile',
          //hbs:'../libs/handlebars/hbs',
          //moment:'../libs/moment',
          //countdown:'../libs/jquery/countdown/jquery.countdown',
          //bootstrap_alert: '../libs/bootstrap/bootstrap-alert',
          //bootstrap_button: '../libs/bootstrap/bootstrap-button',
          //bootstrap_carousel: '../libs/bootstrap/bootstrap-carousel',
          //bootstrap_collapse: '../libs/bootstrap/bootstrap-collapse',
          //bootstrap_dropdown: '../libs/bootstrap/bootstrap-dropdown',
          //bootstrap_modal: '../libs/bootstrap/bootstrap-modal',
          //bootstrap_popover: '../libs/bootstrap/bootstrap-popover',
          //bootstrap_scrollspy: '../libs/bootstrap/bootstrap-scrollspy',
          //bootstrap_tab: '../libs/bootstrap/bootstrap-tab',
          //bootstrap_tooltip: '../libs/bootstrap/bootstrap-tooltip',
          //bootstrap_transition: '../libs/bootstrap/bootstrap-transition',
          //bootstrap_typeahead: '../libs/bootstrap/bootstrap-typeahead',
          //text:'../libs/require/text', // require plugin to load non js file
          //templates:'templates' // path for template files
     //},
     //shim: {
        //'jqueryui': {
            //deps: ['jquery']
        //}
     //},

     //hbs : {
        //templateExtension : 'hbs',
        //// if disableI18n is `true` it won't load locales and the i18n helper
        //// won't work as well.
        //disableI18n : false
    //}
//});


require(['app'], function(App){
   window.DNMAPP = new App();
});
