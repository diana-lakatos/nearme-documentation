var path = require('path');
var modernizr = require('modernizr');
var fs = require('fs');
var gutil = require('gulp-util');
var mkdirp = require('mkdirp');
var uglifyJS = require('uglify-js');
var modernizrConfig = require('../.modernizrrc.json');

function buildModernizr(output, environment, optimize) {

  optimize = optimize || false;

  modernizr.build(modernizrConfig, (result)=>{
    if (optimize) {
      result = uglifyJS.minify(result, {
        fromString: true,
        outSourceMap: 'modernizr.js.map',
        output: {
          comments: /license/i,
        },
        mangle: {
          except: ['Modernizr','jQuery','$', 'exports', 'require']
        }
      });
    }

    /* Create output dir if it doesn't exist */
    mkdirp(output, function(err){
      if (err) {
        gutil.log(gutil.colors.red('Error [modernizr]: ' + err));
        return gutil.beep();
      }

      /* Write output code */
      fs.writeFile(path.join(output, 'modernizr.js'), result.code, function(err) {
        if (err) {
          gutil.log(gutil.colors.red('Error [modernizr]: ' + err));
          return gutil.beep();
        }

        /* Write sourcemap */
        fs.writeFile(path.join(output, 'modernizr.js.map'), result.map, function(err) {
          if (err) {
            gutil.log(gutil.colors.red('Error [modernizr]: ' + err));
            return gutil.beep();
          }

          gutil.log(gutil.colors.yellow('[modernizr] ' + environment + ' build created successfuly'));
        });
      });
    });
  });
}



module.exports = function(gulp, config) {

  gulp.task('modernizr', ['modernizr:development']);

  /* For dev we will attach the full modernizr package with all tests */
  gulp.task('modernizr:development', function(){
    buildModernizr(path.join(config.paths.output, 'vendor'), 'development');
  });

  function registerEnvironmentTasks(gulp, environment) {
    gulp.task(`modernizr:${environment}`, ['styles:dist', `webpack:${environment}`], ()=>{
      buildModernizr(path.join(config.paths.tmp, 'vendor'), environment, true);
    });
  }

  registerEnvironmentTasks(gulp, 'test');
  registerEnvironmentTasks(gulp, 'staging');
  registerEnvironmentTasks(gulp, 'production');
};
