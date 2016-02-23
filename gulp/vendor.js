var path = require('path');
var rename = require('gulp-rename');

module.exports = function(gulp, config){

    gulp.task('ckeditor', function(){
        gulp.src([path.join(config.paths.bower_components, 'ckeditor', '**', '*'), path.join('!', config.paths.bower_components, 'ckeditor', 'config.js')])
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));

        gulp.src(path.join(config.paths.javascripts, 'ckeditor','config.js'))
            .pipe(gulp.dest(path.join(config.paths.output, 'ckeditor')));
    });

    gulp.task('raygun', function() {
        return gulp.src([path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js'), path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js.map')])
            .pipe(gulp.dest(config.paths.output));
    });

    gulp.task('raygun:dist', function(){
        return gulp.src([path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js'), path.join(config.paths.bower_components, 'raygun4js','dist','raygun.min.js.map')])
            .pipe(gulp.dest(config.paths.tmp));
    });

    gulp.task('modernizr', function(){
        gulp.src(path.join(config.paths.javascripts, 'vendor', 'modernizr.js'))
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('modernizr:dist', function(){
        gulp.src(path.join(config.paths.javascripts, 'vendor', 'modernizr.js'))
            .pipe(gulp.dest(path.join(config.paths.tmp, 'vendor')));
    });

    gulp.task('jquery', function() {
        /* Modern browsers */
        gulp.src([path.join(config.paths.bower_components, 'jquery','dist','jquery.min.js'), path.join(config.paths.bower_components, 'jquery','dist','jquery.min.map')])
            .pipe(gulp.dest(config.paths.output));

        /* Legacy IE */
        gulp.src(path.join(config.paths.bower_components, 'jquery-legacy','dist','jquery.min.js'))
            .pipe(rename('jquery-legacy.min.js'))
            .pipe(gulp.dest(config.paths.output));
    });

    gulp.task('jquery:dist', function(){
        /* Modern browsers */
        gulp.src([path.join(config.paths.bower_components, 'jquery','dist','jquery.min.js'), path.join(config.paths.bower_components, 'jquery','dist','jquery.min.map')])
            .pipe(gulp.dest(config.paths.tmp));

        /* Legacy IE */
        gulp.src(path.join(config.paths.bower_components, 'jquery-legacy','dist','jquery.min.js'))
            .pipe(rename('jquery-legacy.min.js'))
            .pipe(gulp.dest(config.paths.tmp));
    });

    gulp.task('polyfills', function(){
        gulp.src([path.join(config.paths.bower_components, 'respond','dest','respond.min.js'), path.join(config.paths.bower_components, 'placeholders','dist','placeholders.min.js')])
            .pipe(gulp.dest(path.join(config.paths.output, 'vendor')));
    });

    gulp.task('polyfills:dist', function(){
        gulp.src([path.join(config.paths.bower_components, 'respond','dest','respond.min.js'), path.join(config.paths.bower_components, 'placeholders','dist','placeholders.min.js')])
            .pipe(gulp.dest(path.join(config.paths.tmp, 'vendor')));
    });


    // Aggregate taks
    gulp.task('vendor', ['modernizr', 'ckeditor', 'raygun', 'jquery', 'polyfills']);
    gulp.task('vendor:dist', ['modernizr:dist', 'ckeditor', 'raygun:dist', 'jquery:dist', 'polyfills:dist']);
}
