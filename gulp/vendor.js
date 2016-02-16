var path = require('path');

module.exports = function(gulp, config){

    gulp.task('ckeditor', function(){
        gulp.src(path.join(config.paths.bower_components, 'ckeditor', '**', '*'))
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
        return gulp.src(path.join(config.paths.bower_components, 'jquery','dist','jquery.js'))
            .pipe(gulp.dest(config.paths.output));
    });

    gulp.task('jquery:dist', function(){
        return gulp.src([path.join(config.paths.bower_components, 'jquery','dist','jquery.min.js'), path.join(config.paths.bower_components, 'jquery','dist','jquery.min.map')])
            .pipe(gulp.dest(config.paths.tmp));
    });

    // Aggregate taks
    gulp.task('vendor', ['modernizr', 'ckeditor', 'raygun', 'jquery']);
    gulp.task('vendor:dist', ['modernizr:dist', 'ckeditor', 'raygun:dist', 'jquery:dist']);
}
