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
}
