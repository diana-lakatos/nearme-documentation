var
    path = require('path'),
    del = require('del'),
    rev = require('gulp-rev'),
    manifest = require('gulp-rev-manifest-rails'),
    cssRevRewrite = require('gulp-rev-css-url');

module.exports = function(gulp, config) {

    gulp.task('clean', del.bind(null, [config.paths.output, config.paths.tmp]));

    /* Dev environment */

    gulp.task('build', ['clean'], function(){
        return gulp.start(['fonts', 'images', 'styles', 'webpack', 'vendor']);
    });

    /* Alias for consistency */
    gulp.task('build:development', ['build']);

    var distTasks = ['fonts:dist', 'images:dist', 'styles:dist', 'vendor:dist'];

    function createManifest(){
        gulp.src(path.join(config.paths.tmp,'**','*'))
            .pipe(rev())
            .pipe(cssRevRewrite())
            .pipe(gulp.dest(config.paths.output))  // write rev'd assets to build dir
            .pipe(manifest())
            .pipe(gulp.dest(config.paths.output)); // write manifest to build dir
    }

    function registerEnvironmentTasks(gulp, environment) {
        gulp.task('build:' + environment, ['clean'], function(){
            return gulp.start(['manifest:' + environment, 'version']);
        });

        gulp.task('manifest:' + environment, distTasks, function(){
            createManifest();
            return gulp.start('webpack:' + environment);
        });
    }

    registerEnvironmentTasks(gulp, 'test');
    registerEnvironmentTasks(gulp, 'staging');
    registerEnvironmentTasks(gulp, 'production');

    // Aliases
    gulp.task('dist', ['build:production']);
};
