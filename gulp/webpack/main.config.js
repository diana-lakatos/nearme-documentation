// global require, __dirname
'use strict';

var path = require('path');
var webpack = require('webpack');
var gutil = require('gulp-util');

const appFolder = path.join(__dirname,'..','..');

var config = {
  appFolder: appFolder,
    /* the base path which will be used to resolve entry points */
  context: path.join(appFolder, 'app', 'frontend', 'javascripts')
};

config.entry = {
  application: 'application-entry.js',
  instanceadmin: 'instanceadmin-entry.js',
  instancewizard: 'instancewizard-entry.js',
  blog: 'blog-entry.js',
  dashboard: 'dashboard-entry.js',
  admin: 'admin-entry.js',
  community: 'community-entry.js',
  'global-admin': 'global-admin-entry.js',
  hallmark: 'hallmark-entry.js'
};

var assetHost = gutil.env.asset_host || '';

config.output = {
  /* this is our app/assets/javascripts directory, which is part of the Sprockets pipeline */
  path: path.join(appFolder, 'public', 'assets'),
  /* the filename of the compiled bundle, e.g. app/assets/javascripts/bundle.js */
  filename: '[name]-bundle.js',
  /* if the webpack code-splitting feature is enabled, this is the path it'll use to download bundles */
  publicPath: assetHost + '/assets/',
  crossOriginLoading: 'anonymous'
};

config.externals = {
  jquery: 'window.jQuery',
  'expose?jQuery|expose?$!jquery': 'window.jQuery',
  modernizr: 'Modernizr'
};

config.resolve = {
  /* tell webpack which extensions to auto search when it resolves modules. With this, */
  /* you'll be able to do `require('./utils')` instead of `require('./utils.js')` */
  extensions: ['', '.js', '.jsx', '.coffee'],
  modulesDirectories: ['node_modules', '.']
};

config.plugins = [
  new webpack.ProvidePlugin({
    '$': 'jquery',
    'jQuery': 'jquery',
    'window.jQuery': 'jquery',
    'Modernizr': 'modernizr',
    '_': 'underscore',
    'React': 'react'
  }),
  new webpack.optimize.DedupePlugin()
];

config.module = {
  loaders: [
    { test: /\.coffee$/, loader: 'coffee-loader' },
    {
      test: /\.jsx?$/,
      exclude: /(node_modules|vendor)/,
      loader: 'babel',
      query: {
        cacheDirectory: true,
        presets: ['react', 'es2015'],
        plugins: ['transform-runtime']
      }
    },
    { test: /\.css$/, loader: 'style-loader!css-loader' },
    { test: require.resolve('react'), loader: 'expose?React' }
  ]
};

module.exports = config;
