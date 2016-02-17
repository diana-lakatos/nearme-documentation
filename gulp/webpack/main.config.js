/* global require, __dirname */
'use strict';

var path = require('path');
var webpack = require('webpack');

var config = module.exports = {
  // the base path which will be used to resolve entry points
  context: path.join(__dirname,'..','..')
};

config.entry = {
    newui: path.join(config.context, 'app','frontend','javascripts','newui-entry.js'),
    application: path.join(config.context, 'app','frontend','javascripts','application-entry.js'),
    instanceadmin: path.join(config.context, 'app','frontend','javascripts','instanceadmin-entry.js'),
    instancewizard: path.join(config.context, 'app','frontend','javascripts','instancewizard-entry.js'),
    blog: path.join(config.context, 'app','frontend','javascripts','blog-entry.js'),
    blogadmin: path.join(config.context, 'app','frontend','javascripts','blogadmin-entry.js'),
    dashboard: path.join(config.context, 'app','frontend','javascripts','dashboard-entry.js'),
    admin: path.join(config.context, 'app','frontend','javascripts','admin-entry.js'),
    community: path.join(config.context, 'app','frontend','javascripts','community-entry.js'),
};

config.output = {
  // this is our app/assets/javascripts directory, which is part of the Sprockets pipeline
  path: path.join(config.context, 'public', 'assets'),
  // the filename of the compiled bundle, e.g. app/assets/javascripts/bundle.js
  filename: '[name]-bundle.js',
  // if the webpack code-splitting feature is enabled, this is the path it'll use to download bundles
  publicPath: '/assets/',
  crossOriginLoading: 'anonymous'
};

config.externals = {
    jquery: 'jQuery',
    modernizr: 'Modernizr'
};

config.resolve = {
  // tell webpack which extensions to auto search when it resolves modules. With this,
  // you'll be able to do `require('./utils')` instead of `require('./utils.js')`
  extensions: ['', '.js', '.coffee'],
  // by default, webpack will search in `web_modules` and `node_modules`. Because we're using
  // Bower, we want it to look in there too
  modulesDirectories: [ 'node_modules', path.join('vendor','assets','bower_components') ],
};

config.plugins = [
  // we need this plugin to teach webpack how to find module entry points for bower files,
  // as these may not have a package.json file
  new webpack.ResolverPlugin([
    new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('.bower.json', ['main'])
  ]),
  new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      Modernizr: 'modernizr'
  })
];

config.module = {
  loaders: [
    { test: /\.coffee$/, loader: 'coffee-loader' }
  ],
};
