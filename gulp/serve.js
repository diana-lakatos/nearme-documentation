var path = require('path');

module.exports = function(gulp, browserSync, config) {

  gulp.task('serve:run', ['styles', 'images', 'fonts', 'watch', 'vendor', 'modernizr'], function(){
    browserSync.init({
      proxy: 'localhost:3000'
    });

    gulp.watch([path.join(config.paths.output, '*-bundle.js')]).on('change', browserSync.reload);
  });

  gulp.task('serve', ['clean'], function() {
    gulp.start('serve:run');
  });
};
