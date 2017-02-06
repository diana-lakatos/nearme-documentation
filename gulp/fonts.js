var path = require('path');

module.exports = function(gulp, config){

  var fonts = path.join(config.paths.fonts,'**','*.{eot,svg,ttf,woff,woff2}');

  gulp.task('fonts', function(){
    return gulp.src(fonts)
               .pipe(gulp.dest( config.paths.output ));
  });

  gulp.task('fonts:dist', function(){
    return gulp.src(fonts)
               .pipe(gulp.dest( config.paths.tmp ));
  });
};
