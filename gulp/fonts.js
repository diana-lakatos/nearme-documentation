var path = require('path');
var del = require('del');

module.exports = function(gulp, config){

  var fonts = path.join(config.paths.fonts,'**','*.{eot,svg,ttf,woff,woff2}');

  gulp.task('fonts:prepare', function(){
    del(path.join(config.paths.fonts, 'font-awesome', '*'));

    /* Copy newest version of font-awesome */
    return gulp.src(path.join(config.paths.node_modules, 'font-awesome', 'fonts', '*.{eot,svg,ttf,woff,woff2}' ))
               .pipe(gulp.dest(path.join(config.paths.fonts, 'font-awesome')));
  });

  gulp.task('fonts', function(){
    return gulp.src(fonts)
               .pipe(gulp.dest( config.paths.output ));
  });

  gulp.task('fonts:dist', function(){
    return gulp.src(fonts)
               .pipe(gulp.dest( config.paths.tmp ));
  });
};
