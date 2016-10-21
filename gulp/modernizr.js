const path = require('path');
const customizr = require('customizr');
const modernizr = require('modernizr');
const modernizrConfigAll = require('modernizr/lib/config-all.json');
const fs = require('fs');
const gutil = require('gulp-util');

/* These tests are excluded solely because they affect design in an unpredictable way due to css classes conflicts */
var excludedTests = ['hidden', 'dom/hidden', 'flash', 'css/columns', 'csscolumns'];

excludedTests.forEach((test)=>{
  var index = modernizrConfigAll['feature-detects'].indexOf(test);
  if (index > -1) {
    modernizrConfigAll['feature-detects'].splice(index, 1);
    gutil.log(gutil.colors.yellow(`Excluded modernizr test: ${test}`));
  }
});

module.exports = function(gulp, config) {

  gulp.task('modernizr', ['modernizr:development']);

  /* For dev we will attach the full modernizr package with all tests */
  gulp.task('modernizr:development', function(){
    modernizr.build(modernizrConfigAll, (result)=>{
      fs.writeFile(path.join(config.paths.output, 'vendor', 'modernizr.js'), result, function(err) {
        if (err) {
          gutil.log(gutil.colors.red('Error (modernizr): ' + err));
          gutil.beep();
        }

        gutil.log(gutil.colors.yellow('Full development build of modernizr.js was created successfuly'));
      });
    });
  });

  function registerEnvironmentTasks(gulp, environment) {
    gulp.task(`modernizr:${environment}`, ['styles:dist', `webpack:${environment}`], ()=>{
      customizr({
        dest: path.join(config.paths.tmp, 'vendor','modernizr.js'),
        options: ['setClasses'],
        uglify: true,
        excludeTests: excludedTests,
        files: {
          src: [path.join(config.paths.tmp, '**/*.{js,css}')]
        }
      });
    });
  }

  registerEnvironmentTasks(gulp, 'test');
  registerEnvironmentTasks(gulp, 'staging');
  registerEnvironmentTasks(gulp, 'production');
};
