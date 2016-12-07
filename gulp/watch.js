module.exports = function(gulp, config) {
  gulp.task('watch:images', function(){
    gulp.watch('**/*', { cwd: config.paths.images }, ['images']);
  });

  gulp.task('watch:fonts', function(){
    gulp.watch('**/*/', { cwd: config.paths.fonts }, ['fonts']);
  });

  gulp.task('watch:scss', function() {

    gulp.watch([
      'application.scss',
      'application_vendor.scss',
      'blog.scss',
      'errors.scss',
      'instance_admin.scss',
      'instance_admin_vendor.scss',
      'instance_wizard.scss',
      'blog/**/*.scss',
      'common/**/*.scss',
      'components/**/*.scss',
      'instance_admin/**/*.scss',
      'instance_wizard/**/*.scss',
      'layout/**/*.scss',
      'pages/**/*.scss',
      'sections/**/*.scss',
      'themes/**/*.scss',
      'user_blog/**/*.scss',
      'vendor/**/*.scss',
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
