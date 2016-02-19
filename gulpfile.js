/* global require, __dirname */

'use strict';

var
    path = require('path'),
    gulp = require('gulp'),
    browserSync = require('browser-sync').create(),
    config = {
        paths: {
            root: __dirname,
            stylesheets: path.join(__dirname, 'app', 'frontend', 'stylesheets'),
            bower_components: path.join(__dirname, 'vendor', 'assets', 'bower_components'),
            javascripts: path.join(__dirname, 'app', 'frontend', 'javascripts'),
            fonts: path.join(__dirname, 'app', 'frontend', 'fonts'),
            images: path.join(__dirname, 'app', 'frontend', 'images'),
            output: path.join(__dirname, 'public', 'assets' ),
            tmp: path.join(__dirname, 'tmp', 'assets')
        }
    };

require('./gulp/styles')(gulp, browserSync, config);
require('./gulp/scripts')(gulp, config);
require('./gulp/fonts')(gulp, config);
require('./gulp/images')(gulp, config);
require('./gulp/vendor')(gulp, config);
require('./gulp/serve')(gulp, browserSync, config);
require('./gulp/watch')(gulp, config);
require('./gulp/build')(gulp, config);
require('./gulp/version')(gulp, config);

gulp.task('default', ['build']);

