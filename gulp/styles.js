var StyleProcessor = require('./utils/style_processor');

module.exports = function(gulp, browserSync, config) {

  let processor = new StyleProcessor({
    appConfig: config,
    gulp: gulp,
    browserSync: browserSync,
    context: config.paths.stylesheets
  });

  /* Dashboard */
  gulp.task('styles:dashboard:app', function(){
    return processor.run('dashboard.scss');
  });

  gulp.task('styles:dashboard:vendor', function(){
    return processor.run('dashboard_vendor.scss');
  });

  gulp.task('styles:dashboard', ['styles:dashboard:app','styles:dashboard:vendor']);

  /* Instance Admin */

  gulp.task('styles:instance_admin:app', function(){
    return processor.run('instance_admin.scss');
  });

  gulp.task('styles:instance_admin:vendor', function(){
    return processor.run('instance_admin_vendor.scss');
  });

  gulp.task('styles:instance_admin', ['styles:instance_admin:app','styles:instance_admin:vendor']);

  /* Application */
  gulp.task('styles:application:app', function(){
    return processor.run('application.scss');
  });

  gulp.task('styles:application:vendor', function(){
    return processor.run('application_vendor.scss');
  });

  gulp.task('styles:application', ['styles:application:app','styles:application:vendor']);

  /* Community */
  gulp.task('styles:community', function(){
    return processor.run('community.scss');
  });

  /* Other */

  gulp.task('styles:other', function(){
    var files = ['global-admin', 'blog', 'errors','instance_wizard'];
    files.forEach(function(val){
      processor.run(`${val}.scss`);
    });
  });

  gulp.task('styles:admin', function(){
    return processor.run('admin.scss');
  });

  gulp.task('styles:global-admin', function(){
    return processor.run('global-admin.scss');
  });

  /* Global task for all styles */
  gulp.task('styles', ['styles:dashboard', 'styles:application', 'styles:instance_admin', 'styles:community', 'styles:other', 'styles:admin']);

  gulp.task('styles:dist', function(){
    return processor.run('*.scss', true);
  });
};
