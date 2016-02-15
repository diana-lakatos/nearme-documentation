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
        return gulp.start(['fonts', 'images', 'styles', 'webpack', 'modernizr', 'ckeditor', 'raygun']);
    });

    /* Alias for consistency */
    gulp.task('build:development', ['build']);


    var distTasks = ['fonts:dist', 'images:dist', 'styles:dist', 'modernizr:dist', 'raygun:dist'];

    function createManifest(){
        gulp.src(path.join(config.paths.tmp,'**','*'))
            .pipe(rev())
            .pipe(cssRevRewrite())
            .pipe(gulp.dest(config.paths.output))  // write rev'd assets to build dir
            .pipe(manifest())
            .pipe(gulp.dest(config.paths.output)); // write manifest to build dir
    }

    /* Test environment */

    gulp.task('build:test', ['clean'], function(){
        return gulp.start('manifest:test');
    });

    gulp.task('manifest:test', distTasks, function(){
        createManifest();
        return gulp.start(['ckeditor', 'webpack:test']);
    });

    /* Staging environment */

    gulp.task('build:staging', ['clean'], function(){
        return gulp.start('manifest:staging');
    });

    gulp.task('manifest:staging', distTasks, function(){
        createManifest();
        return gulp.start(['ckeditor', 'webpack:staging']);
    });

    /* Production environment */

    gulp.task('build:production', ['clean'], function(){
        return gulp.start('manifest:production');
    });

    gulp.task('manifest:production', distTasks, function(){
        createManifest();
        return gulp.start(['ckeditor', 'webpack:production']);
    });

    // Aliases
    gulp.task('dist', ['build:production']);
};
