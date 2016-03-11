var
    gutil = require('gulp-util'),
    path = require('path'),
    gulpIf = require('gulp-if'),
    cache = require('gulp-cache');
    // imagemin = require('gulp-imagemin');

module.exports = function(gulp, config) {

    gulp.task('images', function(){
        return gulp.src(path.join(config.paths.images, '**','*'))
            .pipe(gulp.dest(config.paths.output));
    });

    gulp.task('images:dist', function(){
        return gulp.src(path.join(config.paths.images, '**','*'))
            .pipe(gulp.dest(config.paths.tmp));
    });

    // gulp.task('images:dist', function(){
    //     return gulp.src(path.join(config.paths.images, '**','*'))
    //         .pipe(gulpIf(gulpIf.isFile, cache(imagemin({
    //             progressive: true,
    //             interlaced: true,
    //             // don't remove IDs from SVGs, they are often used
    //             // as hooks for embedding and styling
    //             svgoPlugins: [{cleanupIDs: false}]
    //         }))
    //         .on('error', function (err) {
    //             throw new gutil.PluginError('images', err);
    //         })))
    //         .pipe(gulp.dest(config.paths.tmp));
    // });
};
