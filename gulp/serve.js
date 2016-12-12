const argv = require('yargs').argv;
const path = require('path');

module.exports = function(gulp, browserSync, config) {

  gulp.task('serve:run', ['styles', 'images', 'fonts', 'watch', 'vendor', 'modernizr'], function(){

    const host = argv.marketplace ? `${argv.marketplace}.lvh.me` : 'localhost';

    browserSync.init({
      proxy: `${host}:3000`,
      notify: false
    });

    gulp.watch([path.join(config.paths.output, '*-bundle.js')]).on('change', browserSync.reload);
  });

  gulp.task('serve', ['clean'], function() {
    gulp.start('serve:run');
  });
};
