module.exports = function(gulp, config) {
  gulp.task('watch:images', function(){
    gulp.watch('**/*', { cwd: config.paths.images }, ['images']);
  });

  gulp.task('watch:fonts', function(){
    gulp.watch('**/*/', { cwd: config.paths.fonts }, ['fonts']);
  });

  gulp.task('watch:scss', function() {

    /* APPLICATION */
    gulp.watch([
      '**/*.scss',
      '!dashboard/**/*.scss',
      '!dashboard.scss',
      '!community/**/*.scss',
      '!community.scss',
      '!admin/**/*.scss',
      '!admin.scss',
      '!shared/**/*.scss'
    ], { cwd: config.paths.stylesheets }, ['styles:application', 'styles:instance_admin','styles:other']);

    /* Dashboard */

    /* Watch all updates to vendor libraries */
    gulp.watch('dashboard/vendor/**/*.scss', { cwd: config.paths.stylesheets }, ['styles:dashboard:vendor']);

    /* watch updates to our code */
    gulp.watch([
      'dashboard.scss',
      'dashboard/**/*.scss',
      '!dashboard/vendor/**/*.scss',
      '!dashboard/common/**/*.scss'
    ], { cwd: config.paths.stylesheets } ['styles:dashboard:app']);

    /* update all when updating config and mixins */
    gulp.watch('dashboard/common/**/*.scss', { cwd: config.paths.stylesheets }, ['styles:dashboard']);

    /* Community */
    gulp.watch([
      'community/**/*.scss',
      'community.scss'
    ], { cwd: config.paths.stylesheets }, ['styles:community']);

    gulp.watch([
      'shared/**/*.scss'
    ], { cwd: config.paths.stylesheets }, ['styles:application', 'styles:dashboard']);
  });

  gulp.task('watch', ['watch:scss', 'watch:images', 'watch:fonts', 'watch:webpack', 'watch:lint'], function(){
    gulp.start('modernizr');
  });
};
