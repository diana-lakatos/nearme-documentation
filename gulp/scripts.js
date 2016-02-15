var
    webpack = require('webpack'),
    util = require('gulp-util'),
    path = require('path'),
    fs = require('fs');

module.exports = function(gulp, config) {
    function onWebpackBuild(callback) {
        return function(err, stats) {
            if (err) {
                throw new util.PluginError('webpack', err);
            }
            util.log('[webpack]', stats.toString());

            var chunks = stats.toJson()['assetsByChunkName'];

            fs.writeFile(path.join(config.paths.output, 'webpack-asset-manifest.json'), JSON.stringify(chunks));

            if (callback) {
                callback();
            }
        };
    }

    gulp.task('webpack', function(callback) {
        var webpackConfig = require('./webpack/development.config');
        var output = webpack(webpackConfig).run(onWebpackBuild(callback));
    });

    gulp.task('watch:webpack', function() {
        var webpackConfig = require('./webpack/development.config');
        webpack(webpackConfig).watch(100, onWebpackBuild());
    });

    gulp.task('webpack:test', function(callback) {
        var webpackConfig = require('./webpack/test.config');
        webpack(webpackConfig).run(onWebpackBuild(callback));
    });

    gulp.task('webpack:staging', function(callback) {
        var webpackConfig = require('./webpack/staging.config');
        webpack(webpackConfig).run(onWebpackBuild(callback));
    });

    gulp.task('webpack:production', function(callback) {
        var webpackConfig = require('./webpack/production.config');
        webpack(webpackConfig).run(onWebpackBuild(callback));
    });
};
