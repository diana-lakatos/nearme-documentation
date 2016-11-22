var path = require('path');

module.exports = function(gulp, config) {

  gulp.task('images', function(){
    return gulp.src(path.join(config.paths.images, '**','*'))
            .pipe(gulp.dest(config.paths.output));
  });

  /* There is no image optimisation here - it was killing staging */
  gulp.task('images:dist', function(){
    return gulp.src(path.join(config.paths.images, '**','*'))
            .pipe(gulp.dest(config.paths.tmp));
  });
};
