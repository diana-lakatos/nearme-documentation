const StyleProcessor = require('./utils/style_processor');

module.exports = function(gulp, browserSync, config) {

  /* CSS */
  let processor = new StyleProcessor({
    appConfig: config,
    gulp: gulp,
    browserSync: browserSync,
    context: config.paths.stylesheets
  });

  gulp.task('styles:hallmark', function(){
    return processor.run('hallmark.scss');
  });

  gulp.tasks.styles.dep.push('styles:hallmark');

  /* WATCH */
  gulp.task('watch:hallmark', function() {
    gulp.watch([
      'hallmark.scss',
      'hallmark/**/*.scss',
    ], { cwd: config.paths.stylesheets }, ['styles:hallmark']);
  });

  gulp.tasks.watch.dep.push('watch:hallmark');
};

