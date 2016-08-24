var
    webpack = require('webpack'),
    gutil = require('gulp-util'),
    path = require('path'),
    fs = require('fs');

module.exports = function(gulp, config) {
    function onWebpackBuild(callback, output) {

        output = output || config.paths.output;

        return function(err, stats) {
            if (err) {
                throw new gutil.PluginError('webpack', err);
            }

            var jsonStats = stats.toJson();

            if (jsonStats['errors'].length > 0) {
                jsonStats['errors'].forEach(function(message){
                    gutil.log(gutil.colors.red('Error (webpack): ' + message));
                    gutil.beep();
                });
            }

            if (jsonStats['warnings'].length > 0) {
                jsonStats['warnings'].forEach(function(message){
                    gutil.log(gutil.colors.yellow('Warning (webpack): ' + message));
                });
            }

            fs.lstat(output, function(err){
                if (err && err.code == 'ENOENT') {
                    fs.mkdirSync(output);
                }

                fs.writeFile(path.join(output, 'webpack-asset-manifest.json'), JSON.stringify(jsonStats['assetsByChunkName']), function(err){
                    if (err) {
                        throw new gutil.PluginError('webpack', err);
                    }
                });
            });

            if (callback) {
                callback();
            }
        };
    }

    gulp.task('webpack', function(callback) {
        var webpackConfig = require('./webpack/development.config');
        webpack(webpackConfig).run(onWebpackBuild(callback, config.paths.tmp));
    });

    gulp.task('watch:webpack', function() {
        var webpackConfig = require('./webpack/development.config');
        webpack(webpackConfig).watch(100, onWebpackBuild());
    });

    gulp.task('webpack:test', function(callback) {
        var webpackConfig = require('./webpack/test.config');
        webpack(webpackConfig).run(onWebpackBuild(callback, config.paths.tmp));
    });

    gulp.task('webpack:staging', function(callback) {
        var webpackConfig = require('./webpack/staging.config');
        webpack(webpackConfig).run(onWebpackBuild(callback, config.paths.tmp));
    });

    gulp.task('webpack:production', function(callback) {
        var webpackConfig = require('./webpack/production.config');
        webpack(webpackConfig).run(onWebpackBuild(callback, config.paths.tmp));
    });
};
