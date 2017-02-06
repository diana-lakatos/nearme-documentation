var
  path = require('path'),
  del = require('del'),
  rev = require('gulp-rev'),
  manifest = require('gulp-rev-manifest-rails'),
  revReplace = require('gulp-rev-replace'),
  rename = require('gulp-rename'),
  filter = require('gulp-filter'),
  vinylPaths = require('vinyl-paths');

module.exports = function(gulp, config) {

  gulp.task('clean', [], del.bind(null, [config.paths.output, config.paths.tmp]));

  /* Dev environment */
  gulp.task('build', ['clean'], function(){
    return gulp.start(['fonts', 'images', 'modernizr', 'vendor', 'styles', 'webpack']);
  });

  /* Alias for consistency */
  gulp.task('build:development', ['build']);

  var distTasks = ['fonts:dist', 'images:dist', 'vendor:dist'];

  function registerEnvironmentTasks(gulp, environment) {
    gulp.task('build:' + environment, ['clean'], function(){
      return gulp.start(['webpack-manifest:' + environment]);
    });

    gulp.task('manifest:' + environment, distTasks.concat(['modernizr:' + environment]), function(){
      var f = filter(function(file){
        return /webpack-(common|asset)-manifest-[a-f0-9]+\.json$/.test(file.path) === false;
      });

      return gulp.src(path.join(config.paths.tmp,'**','*'))
        .pipe(rev())
        .pipe(revReplace({
          replaceInExtensions: ['.json','.js','.css']
        }))
        .pipe(gulp.dest(config.paths.output))  // write rev'd assets to build dir
        .pipe(f) // do not output webpack manifest files in global manifest.json
        .pipe(manifest())
        .pipe(gulp.dest(config.paths.output)); // write manifest to build dir
    });

    gulp.task('webpack-manifest:' + environment, ['manifest:' + environment], function(){
      /* at this point we have webpack-asset-manifest and webpack-common-manifest
      as revisioned files as well, so we need to remove digests from these files */
      return gulp.src(path.join(config.paths.output,'webpack-*-manifest-*.json'))
        .pipe(vinylPaths(del))  // clean up old revisioned files
        .pipe(rename(function(path){
          path.basename = path.basename.replace(/webpack-(common|asset)-manifest-[a-f0-9]+/, 'webpack-$1-manifest');
        }))
        .pipe(gulp.dest(config.paths.output));
    });
  }

  registerEnvironmentTasks(gulp, 'test');
  registerEnvironmentTasks(gulp, 'staging');
  registerEnvironmentTasks(gulp, 'production');

  /* Aliases */
  gulp.task('dist', ['build:production']);
};
