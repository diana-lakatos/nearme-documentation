var path = require('path');
var fs = require('fs');
var gutil = require('gulp-util');
var modernizr = require('gulp-modernizr');
var del = require('del');

module.exports = function(gulp, config){

    var files = {
        ckeditor: path.join(config.paths.node_modules, 'ckeditor'),
        ckeditorConfig: path.join(config.paths.javascripts, 'ckeditor','config.js'),
        ckeditorFileuploader: path.join(config.paths.root, 'vendor', 'gems','ckeditor', 'assets'),
        raygun: path.join(config.paths.node_modules, 'raygun4js','dist','raygun.min.js'),
        raygunMap: path.join(config.paths.node_modules, 'raygun4js','dist','raygun.min.js.map'),
        jquery: path.join(config.paths.node_modules, 'jquery', 'dist', 'jquery.min.js'),
        jqueryMap: path.join(config.paths.node_modules, 'jquery', 'dist', 'jquery.min.map'),
        placeholders: path.join(config.paths.javascripts, 'vendor', 'placeholders.js')
    };

    var modernizrConfig = {
        options: ['setClasses'],
        tests: ['geolocation', 'svg', 'touchevents', 'canvas', 'filereader']
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

        gulp.src([files.ckeditorConfig, path.join(files.ckeditorFileuploader, '**', '*')])
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));
    });

    gulp.task('vendor:ckeditor:dist', function(){
        gulp.src([path.join(files.ckeditorFileuploader, '**', '*')])
            .pipe(gulp.dest(path.join(config.paths.tmp, 'ckeditor')));

        gulp.src([path.join(files.ckeditor, '**', '*'), path.join('!', files.ckeditor, 'config.js')])
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));

        gulp.src([files.ckeditorConfig])
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
        gulp.src(path.join(config.paths.javascripts, '*.js'))
            .pipe(modernizr(modernizrConfig))
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('vendor:modernizr:dist', function(){
        gulp.src(path.join(config.paths.javascripts, '*.js'))
            .pipe(modernizr(modernizrConfig))
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
    // TODO: Verify if problem still occurs
    gulp.task('vendor:jquery:update', function(){
        var libDir = path.join(config.paths.javascripts, 'vendor', 'jquery');
        del(libDir);

        gulp.src([
            path.join(config.paths.node_modules, 'jquery', 'dist', 'jquery.min.js'),
            path.join(config.paths.node_modules, 'jquery', 'dist', 'jquery.min.map')
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
    gulp.task('vendor:dist', ['vendor:checkfiles', 'vendor:modernizr:dist', 'vendor:ckeditor:dist', 'vendor:raygun:dist', 'vendor:jquery:dist', 'vendor:polyfills:dist']);
};
