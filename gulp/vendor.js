var path = require('path');
var rename = require('gulp-rename');
var fs = require('fs');
var gutil = require('gulp-util');

module.exports = function(gulp, config){

    var files = {
        ckeditor: path.join(config.paths.bower_components, 'ckeditor'),
        ckeditorConfig: path.join(config.paths.javascripts, 'ckeditor','config.js'),
        raygun: path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js'),
        raygunMap: path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js.map'),
        modernizr: path.join(config.paths.javascripts, 'vendor', 'modernizr.js'),
        jquery: path.join(config.paths.bower_components, 'jquery','dist','jquery.min.js'),
        jqueryMap: path.join(config.paths.bower_components, 'jquery','dist','jquery.min.map'),
        jqueryLegacy: path.join(config.paths.bower_components, 'jquery-legacy','dist','jquery.min.js'),
        respond: path.join(config.paths.bower_components, 'respond','dest','respond.min.js'),
        placeholders: path.join(config.paths.bower_components, 'placeholders','dist','placeholders.min.js')
    };

    for (var file in files) {
        fs.stat(files[file], function(err, stat) {
            if(err) {
                gutil.beep();
                throw err;
            }
        });
    }

    gulp.task('ckeditor', function(){
        gulp.src([path.join(files.ckeditor, '**', '*'), path.join('!', files.ckeditorConfig)])
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));

        gulp.src(files.ckeditorConfig)
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));
    });

    gulp.task('raygun', function() {
        return gulp.src([files.raygun, files.raygunMap])
            .pipe(gulp.dest(config.paths.output));
    });

    gulp.task('raygun:dist', function(){
        return gulp.src([files.raygun, files.raygunMap])
            .pipe(gulp.dest(config.paths.tmp));
    });

    gulp.task('modernizr', function(){
        gulp.src(files.modernizr)
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('modernizr:dist', function(){
        gulp.src(files.modernizr)
            .pipe(gulp.dest(path.join(config.paths.tmp, 'vendor')));
    });

    gulp.task('jquery', function() {
        /* Modern browsers */
        gulp.src([files.jquery, files.jqueryMap])
            .pipe(gulp.dest(config.paths.output));

        /* Legacy IE */
        gulp.src(files.jqueryLegacy)
            .pipe(rename('jquery-legacy.min.js'))
            .pipe(gulp.dest(config.paths.output));
    });

    gulp.task('jquery:dist', function(){
        /* Modern browsers */
        gulp.src([files.jquery, files.jqueryMap])
            .pipe(gulp.dest(config.paths.tmp));

        /* Legacy IE */
        gulp.src(files.jqueryLegacy)
            .pipe(rename('jquery-legacy.min.js'))
            .pipe(gulp.dest(config.paths.tmp));
    });

    gulp.task('polyfills', function(){
        gulp.src([files.respond, files.placeholders])
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('polyfills:dist', function(){
        gulp.src([files.respond, files.placeholders])
            .pipe(gulp.dest(path.join(config.paths.tmp, 'vendor')));
    });


    // Aggregate taks
    gulp.task('vendor', ['modernizr', 'ckeditor', 'raygun', 'jquery', 'polyfills']);
    gulp.task('vendor:dist', ['modernizr:dist', 'ckeditor', 'raygun:dist', 'jquery:dist', 'polyfills:dist']);
}
