var path = require('path');
var fs = require('fs');
var gutil = require('gulp-util');
var del = require('del');

module.exports = function(gulp, config){

    var files = {
        ckeditor: path.join(config.paths.bower_components, 'ckeditor'),
        ckeditorConfig: path.join(config.paths.javascripts, 'ckeditor','config.js'),
        raygun: path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js'),
        raygunMap: path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js.map'),
        modernizr: path.join(config.paths.javascripts, 'vendor', 'modernizr.js'),
        jquery: path.join(config.paths.javascripts, 'vendor', 'jquery','jquery.min.js'),
        jqueryMap: path.join(config.paths.javascripts, 'vendor', 'jquery','jquery.min.map'),
        placeholders: path.join(config.paths.bower_components, 'placeholders','dist','placeholders.min.js')
    };

    gulp.task('vendor:checkfiles', function(){
        for (var file in files) {
            fs.stat(files[file], function(err) {
                if(err) {
                    gutil.beep();
                    throw err;
                }
            });
        }
    });

    gulp.task('vendor:ckeditor', function(){
        gulp.src([path.join(files.ckeditor, '**', '*'), path.join('!', files.ckeditor, 'config.js')])
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));

        gulp.src(files.ckeditorConfig)
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));
    });

    gulp.task('vendor:raygun', function() {
        return gulp.src([files.raygun, files.raygunMap])
            .pipe(gulp.dest(config.paths.output));
    });

    gulp.task('vendor:raygun:dist', function(){
        return gulp.src([files.raygun, files.raygunMap])
            .pipe(gulp.dest(config.paths.tmp));
    });

    gulp.task('vendor:modernizr', function(){
        gulp.src(files.modernizr)
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('vendor:modernizr:dist', function(){
        gulp.src(files.modernizr)
            .pipe(gulp.dest(path.join(config.paths.tmp, 'vendor')));
    });

    gulp.task('vendor:jquery', function() {
        gulp.src([files.jquery, files.jqueryMap])
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('vendor:jquery:dist', function(){
        gulp.src([files.jquery, files.jqueryMap])
            .pipe(gulp.dest(path.join(config.paths.tmp, 'vendor')));
    });

    // Due to unexpected behaviour of tests on Semaphore this is stored
    // inside of vendor libraries in application rather than from bower
    // Should revisit at some point to make sure jquery repository structure
    // is not changing anymore when on Semaphore, resulting in missing jquery files
    gulp.task('vendor:jquery:update', function(){
        var libDir = path.join(config.paths.javascripts,'vendor','jquery');
        del(libDir);

        gulp.src([
            path.join(config.paths.bower_components, 'jquery','dist','jquery.min.js'),
            path.join(config.paths.bower_components, 'jquery','dist','jquery.min.map')
        ])
        .pipe(gulp.dest(libDir));

        gulp.start('vendor:checkfiles');
    });

    gulp.task('vendor:polyfills', function(){
        gulp.src([files.placeholders])
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('vendor:polyfills:dist', function(){
        gulp.src([files.placeholders])
            .pipe(gulp.dest(path.join(config.paths.tmp, 'vendor')));
    });

    // Aggregate taks
    gulp.task('vendor', ['vendor:checkfiles', 'vendor:modernizr', 'vendor:ckeditor', 'vendor:raygun', 'vendor:jquery', 'vendor:polyfills']);
    gulp.task('vendor:dist', ['vendor:checkfiles', 'vendor:modernizr:dist', 'vendor:ckeditor', 'vendor:raygun:dist', 'vendor:jquery:dist', 'vendor:polyfills:dist']);
};
