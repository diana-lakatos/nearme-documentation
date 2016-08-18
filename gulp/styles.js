var
    path = require('path'),
    plumber = require('gulp-plumber'),
    sass = require('gulp-sass'),
    postcss = require('gulp-postcss'),
    autoprefixer = require('autoprefixer'),
    sourcemaps = require('gulp-sourcemaps'),
    cssnano = require('gulp-cssnano'),
    gutil = require('gulp-util');


module.exports = function(gulp, browserSync, config) {

    var sassConfig = {
        outputStyle: 'expanded',
        precision: 10,
        includePaths: ['.', config.paths.bower_components, config.paths.node_modules]
    };

    function processStyles(files) {
        return gulp.src(files)
            .pipe(plumber())
            .pipe(sourcemaps.init())
            .pipe(sass.sync(sassConfig).on('error', function(err){
                gutil.log(gutil.colors.red('Error (sass): ' + err.formatted));
                gutil.beep();
            }))
            .pipe(postcss([ autoprefixer({ browsers: ['last 2 versions'] }) ]))
            .pipe(sourcemaps.write('.'))
            .pipe(gulp.dest(config.paths.output))
            .pipe(browserSync.stream({ match: '**/*.css' })); /* match makes sure we do not refresh whole page due to .map file being generated */
    }

    /* New UI */

    gulp.task('styles:newui:app', function(){
        return processStyles(path.join(config.paths.stylesheets, 'new_ui', 'new_ui.scss'));
    });

    gulp.task('styles:newui:vendor', function(){
        return processStyles(path.join(config.paths.stylesheets, 'new_ui', 'new_ui_vendor.scss'));
    });

    gulp.task('styles:newui', ['styles:newui:app','styles:newui:vendor']);

    /* New UI */

    gulp.task('styles:instance_admin:app', function(){
        return processStyles(path.join(config.paths.stylesheets, 'instance_admin.scss'));
    });

    gulp.task('styles:instance_admin:vendor', function(){
        return processStyles(path.join(config.paths.stylesheets, 'instance_admin_vendor.scss'));
    });

    gulp.task('styles:instance_admin', ['styles:instance_admin:app','styles:instance_admin:vendor']);

    /* Application */
    gulp.task('styles:application:app', function(){
        return processStyles(path.join(config.paths.stylesheets, 'application.scss'));
    });

    gulp.task('styles:application:vendor', function(){
        return processStyles(path.join(config.paths.stylesheets, 'application_vendor.scss'));
    });

    gulp.task('styles:application', ['styles:application:app','styles:application:vendor']);

    /* Intel */
    gulp.task('styles:intel', function(){
        return processStyles(path.join(config.paths.stylesheets, 'community.scss'));
    });

    /* Other */

    gulp.task('styles:other', function(){
        var files = ['admin', 'blog', 'dashboard', 'errors','instance_wizard'];
        files = files.map(function(val){
            return path.join(config.paths.stylesheets, val + '.scss');
        });
        return processStyles(files);
    });

    /* Global task for all styles */
    gulp.task('styles', ['styles:newui', 'styles:application', 'styles:instance_admin', 'styles:intel', 'styles:other']);

    gulp.task('styles:dist', function(){
        return gulp.src([path.join(config.paths.stylesheets, '*.scss'), path.join(config.paths.stylesheets, 'new_ui', '*.scss')])
        .pipe(plumber())
        .pipe(sourcemaps.init())
        .pipe(sass.sync(sassConfig).on('error', sass.logError))
        .pipe(postcss([ autoprefixer({ browsers: ['last 2 versions'] }) ]))
        .pipe(cssnano({ safe: true }))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest(config.paths.tmp));
    });
};
