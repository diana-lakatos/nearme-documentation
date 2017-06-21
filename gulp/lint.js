'use strict';

var
  eslint = require('gulp-eslint'),
  path = require('path'),
  cache = require('gulp-cached'),
  flow = require('gulp-flowtype');


module.exports = function(gulp){

  var files = [
    'gulp/**/*.js',
    'app/frontend/javascripts/*.js',
    'app/frontend/javascripts/**/*.js'
  ];


  gulp.task('lint:javascript', function () {
    return gulp.src(files)
    .pipe(eslint())
    .pipe(eslint.format())
    .pipe(eslint.failAfterError());
  });

  gulp.task('lint:typecheck', function() {
    return gulp.src(files)
    .pipe(flow({
      // declarations: './declarations',
      killFlow: false,
      beep: true,
      abort: false
    }));
  });

  gulp.task('lint', ['lint:javascript']);


  gulp.task('lint:javascript:cached', function() {
    /* Read all js files */
    return gulp.src(files)
    .pipe(cache('eslint'))
    /* Only uncached and changed files past this point */
    .pipe(eslint())
    .pipe(eslint.format())
    .pipe(eslint.result(function(result) {
      if (result.warningCount > 0 || result.errorCount > 0) {
        /* If a file has errors/warnings remove uncache it */
        delete cache.caches.eslint[path.resolve(result.filePath)];
      }
    }));
  });

  /* Run the "lint:javascript:cached" task initially... */
  gulp.task('watch:lint:javascript', ['lint:javascript:cached'], function() {
    /* ...and whenever a watched file changes */
    return gulp.watch(files, { interval: 500 }, ['lint:javascript:cached'], function(event) {
      if (event.type === 'deleted' && cache.caches.eslint) {
        /* remove deleted files from cache */
        delete cache.caches.eslint[event.path];
      }
    });
  });

  gulp.task('watch:lint:typecheck', ['lint:typecheck'], function(){
    return gulp.watch(files, { interval: 500 }, ['lint:typecheck']);
  });


  gulp.task('watch:lint', ['watch:lint:javascript']);
};
