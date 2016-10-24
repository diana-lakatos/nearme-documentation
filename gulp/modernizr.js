var path = require('path');
var customizr = require('customizr');
var modernizr = require('modernizr');
var modernizrConfigAll = require('modernizr/lib/config-all.json');
var fs = require('fs');
var gutil = require('gulp-util');
var mkdirp = require('mkdirp');

/* These tests are excluded solely because they affect design in an unpredictable way due to css classes conflicts */
var excludedTests = ['hidden', 'dom/hidden', 'flash', 'css/columns', 'csscolumns'];

var tests = [
  'animation',
  'canvas',
  'checked',
  'contains',
  'cssanimations',
  'csscalc',
  'cssgradients',
  'csspointerevents',
  'csstransforms',
  'details',
  'filereader',
  'flexbox',
  'geolocation',
  'hsla',
  'input',
  'opacity',
  'placeholder',
  'progressbar_meter',
  'rgba',
  'search',
  'sizes',
  'svg',
  'target',
  'template',
  'texttrackapi_track',
  'time',
  'touchevents',
  'setclasses'
];

var options = [
  'setClasses'
];

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
      mkdirp(path.join(config.paths.output, 'vendor'), function(err){
        if (err) {
          gutil.log(gutil.colors.red('Error (modernizr): ' + err));
          gutil.beep();
        }
        else {
          fs.writeFile(path.join(config.paths.output, 'vendor', 'modernizr.js'), result, function(err) {
            if (err) {
              gutil.log(gutil.colors.red('Error (modernizr): ' + err));
              gutil.beep();
            }
            else {
              gutil.log(gutil.colors.yellow('Full development build of modernizr.js was created successfuly'));
            }
          });
        }
      });

    });
  });

  function registerEnvironmentTasks(gulp, environment) {
    gulp.task(`modernizr:${environment}`, ['styles:dist', `webpack:${environment}`], ()=>{
      customizr({
        dest: path.join(config.paths.tmp, 'vendor','modernizr.js'),
        options: options,
        uglify: true,
        tests: tests,
        excludeTests: excludedTests,
        crawl: false
      });
    });
  }

  registerEnvironmentTasks(gulp, 'test');
  registerEnvironmentTasks(gulp, 'staging');
  registerEnvironmentTasks(gulp, 'production');
};
