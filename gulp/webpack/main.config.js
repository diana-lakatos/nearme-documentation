/* global require, __dirname */
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
    newui: 'newui-entry.js',
    application: 'application-entry.js',
    instanceadmin: 'instanceadmin-entry.js',
    instancewizard: 'instancewizard-entry.js',
    blog: 'blog-entry.js',
    blogadmin: 'blogadmin-entry.js',
    dashboard: 'dashboard-entry.js',
    admin: 'admin-entry.js',
    community: 'community-entry.js'
};

var assetHost = gutil.env.asset_host || '';

config.output = {
    // this is our app/assets/javascripts directory, which is part of the Sprockets pipeline
    path: path.join(appFolder, 'public', 'assets'),
    // the filename of the compiled bundle, e.g. app/assets/javascripts/bundle.js
    filename: '[name]-bundle.js',
    // if the webpack code-splitting feature is enabled, this is the path it'll use to download bundles
    publicPath: assetHost + '/assets/',
    crossOriginLoading: 'anonymous'
};

config.externals = {
    jquery: 'window.jQuery',
    'expose?jQuery|expose?$!jquery': 'window.jQuery',
    modernizr: 'Modernizr'
};

config.resolve = {
    // tell webpack which extensions to auto search when it resolves modules. With this,
    // you'll be able to do `require('./utils')` instead of `require('./utils.js')`
    extensions: ['', '.js', '.coffee'],
    // by default, webpack will search in `web_modules` and `node_modules`. Because we're using
    // Bower, we want it to look in there too
    modulesDirectories: [ '.', 'node_modules', path.join('vendor','assets','bower_components') ],
};

config.plugins = [
    // we need this plugin to teach webpack how to find module entry points for bower files,
    // as these may not have a package.json file
    new webpack.ResolverPlugin([
        new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('.bower.json', ['main'])
    ]),
    new webpack.ProvidePlugin({
        '$': 'jquery',
        'jQuery': 'jquery',
        'window.jQuery': 'jquery',
        'Modernizr': 'modernizr',
        '_': 'underscore'
    }),
    new webpack.optimize.DedupePlugin()
];

config.module = {
    loaders: [
        { test: /\.coffee$/, loader: 'coffee-loader' },
        {
            test: /\.jsx?$/,
            exclude: /(node_modules|bower_components|vendor)/,
            loader: 'babel',
            query: {
                cacheDirectory: true,
                presets: ['es2015', 'react'],
                plugins: ['transform-runtime']
            }
        },
        { test: /\.css$/, loader: 'style-loader!css-loader' }
    ]
};

module.exports = config;
