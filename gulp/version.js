var path = require('path');
var git  = require('gulp-git');
var gutil = require('gulp-util');
var bump = require('gulp-bump');
var _ = require('lodash');
var plumber = require('gulp-plumber');

module.exports = function(gulp, config){

  gulp.task('version', function(){

    git.exec({ args: 'describe', quiet: true }, function(err, stdout){
      if (err) {
        throw new gutil.PluginError('version', err);
      }

      var version = _.trim(stdout);
      var tags = version.match(/^([0-9]+\.[0-9]+\.[0-9]+)(-[0-9]+)?(-[0-9a-z]+)?$/i);
      if (tags) {
        version = tags[1] + (tags[2] || '-0');
      }
      else {
        gutil.log(gutil.colors.red('Error (version): Unable to read version from git describe. Setting to 0.0.0'));
        version = '0.0.0';
      }


      gulp.src([path.join(config.paths.root, './package.json')])
                .pipe(plumber())
                .pipe(bump({ version: version }))
                .pipe(gulp.dest(config.paths.root));
    });
  });
};
