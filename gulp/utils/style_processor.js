const
  path = require('path'),
  plumber = require('gulp-plumber'),
  sass = require('gulp-sass'),
  postcss = require('gulp-postcss'),
  autoprefixer = require('autoprefixer'),
  sourcemaps = require('gulp-sourcemaps'),
  gutil = require('gulp-util'),
  cssnano = require('gulp-cssnano'),
  gulpIf = require('gulp-if');

class StyleProcessor {
  constructor(options) {
    this.appConfig = options.appConfig;
    this.gulp = options.gulp;
    this.browserSync = options.browserSync;
    this.context = options.context || '';
  }

  getSassConfig() {
    return {
      outputStyle: 'expanded',
      precision: 10,
      includePaths: ['.', this.appConfig.paths.node_modules]
    };
  }

  run(files, dist = false) {

    const output = dist ? this.appConfig.paths.tmp : this.appConfig.paths.output;

    const onSassError = dist ? sass.logError : (err)=>{
      gutil.log(gutil.colors.red('Error (sass): ' + err.formatted));
      gutil.beep();
    };

    return this.gulp.src(path.join(this.context, files))
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(sass.sync(this.getSassConfig()).on('error', onSassError))
    .pipe(postcss([ autoprefixer({ browsers: ['last 2 versions'] }) ]))
    .pipe(gulpIf(dist, cssnano({ safe: true })))
    .pipe(sourcemaps.write('.'))
    .pipe(this.gulp.dest(output))
    .pipe(gulpIf(!dist, this.browserSync.stream({ match: '**/*.css' }))); /* match makes sure we do not refresh whole page due to .map file being generated */
  }
}

module.exports = StyleProcessor;
