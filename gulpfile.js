/* global require, __dirname */

'use strict';

var
    gulp, sass, sourcemaps, autoprefixer, plumber,
    browserSync, webpack, util, webpackConfig, sassConfig, path,
    frontendCssPath, frontendJsPath, frontendFontsPath, frontendImagesPath,
    outputPath, tmpAssetsPath,
    cssnano, postcss, del,
    cache, gulpIf, imagemin,
    manifest, rev, uglify, cssRevRewrite,
    bower_components;

gulp = require('gulp');
sass = require('gulp-sass');
postcss = require('gulp-postcss');
autoprefixer = require('autoprefixer');
sourcemaps = require('gulp-sourcemaps');
plumber = require('gulp-plumber');
browserSync = require('browser-sync').create();
webpack = require('webpack');
util = require('gulp-util');
path = require('path');
cssnano = require('gulp-cssnano');
del = require('del');
gulpIf = require('gulp-if');
cache = require('gulp-cache');
imagemin = require('gulp-imagemin');
rev = require('gulp-rev');
manifest = require('gulp-rev-manifest-rails');
uglify = require('gulp-uglify');
cssRevRewrite=require('gulp-rev-css-url');

webpackConfig = require(path.join(__dirname, 'config', 'webpack', 'development.config.js'));

sassConfig = {
    outputStyle: 'expanded',
    precision: 10,
    includePaths: ['.', path.join(__dirname, 'vendor', 'assets', 'bower_components')]
};

bower_components    = path.join(__dirname, 'vendor', 'assets', 'bower_components');
frontendCssPath     = path.join(__dirname, 'app', 'frontend', 'stylesheets');
frontendJsPath      = path.join(__dirname, 'app', 'frontend', 'javascripts');
frontendFontsPath   = path.join(__dirname, 'app', 'frontend', 'fonts');
frontendImagesPath  = path.join(__dirname, 'app', 'frontend', 'images');
outputPath          = path.join(__dirname, 'public', 'assets' );
tmpAssetsPath       = path.join(__dirname, 'tmp', 'assets');

/* STYLES */

function processStyles(files) {
    return gulp.src(files)
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(sass.sync(sassConfig).on('error', sass.logError))
    .pipe(postcss([ autoprefixer({ browsers: ['last 2 versions'] }) ]))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(outputPath))
    .pipe(browserSync.stream({ match: '**/*.css' })); /* match makes sure we do not refresh whole page due to .map file being generated */
}

/* New UI */

gulp.task('styles:newui:app', function(){
    return processStyles(path.join(frontendCssPath, 'new_ui', 'new_ui.scss'));
});

gulp.task('styles:newui:vendor', function(){
    return processStyles(path.join(frontendCssPath, 'new_ui', 'new_ui_vendor.scss'));
});

gulp.task('styles:newui', ['styles:newui:app','styles:newui:vendor']);

/* New UI */

gulp.task('styles:instance_admin:app', function(){
    return processStyles(path.join(frontendCssPath, 'instance_admin.scss'));
});

gulp.task('styles:instance_admin:vendor', function(){
    return processStyles(path.join(frontendCssPath, 'instance_admin_vendor.scss'));
});

gulp.task('styles:instance_admin', ['styles:instance_admin:app','styles:instance_admin:vendor']);

/* Application */
gulp.task('styles:application:app', function(){
    return processStyles(path.join(frontendCssPath, 'application.scss'));
});

gulp.task('styles:application:vendor', function(){
    return processStyles(path.join(frontendCssPath, 'application_vendor.scss'));
});

gulp.task('styles:application', ['styles:application:app','styles:application:vendor']);

/* Intel */
gulp.task('styles:intel', function(){
    return processStyles(path.join(frontendCssPath, 'community.scss'));
});

/* Other */

gulp.task('styles:other', function(){
    return processStyles(path.join(frontendCssPath, 'admin.scss'));
});

gulp.task('styles:other', function(){
    var files = ['admin', 'blog', 'blog_admin', 'dashboard', 'errors','instance_wizard'];
    files = files.map(function(val){
        return path.join(frontendCssPath, val + '.scss');
    });
    return processStyles(files);
});

/* Global task for all styles */
gulp.task('styles', ['styles:newui', 'styles:application', 'styles:instance_admin', 'styles:intel', 'styles:other']);

gulp.task('styles:dist', function(){
    return gulp.src([path.join(frontendCssPath, '*.scss'), path.join(frontendCssPath, 'new_ui', '*.scss')])
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(sass.sync(sassConfig).on('error', sass.logError))
    .pipe(postcss([ autoprefixer({ browsers: ['last 2 versions'] }) ]))
    .pipe(cssnano({ safe: true }))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(tmpAssetsPath));
});


/* JAVASCRIPT */

function onWebpackBuild(callback) {
    return function(err, stats) {
        if (err) {
            throw new util.PluginError('webpack', err);
        }
        util.log('[webpack]', stats.toString());
        if (callback) {
            callback();
        }
    };
}

gulp.task('webpack', function(callback) {
    webpack(webpackConfig).run(onWebpackBuild(callback));
});

gulp.task('modernizr', function(){
    gulp.src(path.join(frontendJsPath, 'vendor', 'modernizr.js'))
        .pipe(gulp.dest(path.join(outputPath, 'vendor')));
});

gulp.task('modernizr:dist', function(){
    gulp.src(path.join(frontendJsPath, 'vendor', 'modernizr.js'))
        .pipe(uglify())
        .pipe(gulp.dest(path.join(tmpAssetsPath, 'vendor')));
});

/* Vendor scripts - CKEDITOR */
gulp.task('ckeditor', function(){
    gulp.src(path.join(bower_components, 'ckeditor', '**', '*'))
        .pipe(gulp.dest(path.join(outputPath, 'ckeditor')));
});



/* browser sync */

gulp.task('serve', ['styles', 'images', 'fonts', 'watch', 'modernizr', 'ckeditor', 'raygun'], function() {

    browserSync.init({
        proxy: 'localhost:3000'
    });

    gulp.watch([path.join(outputPath, '*-bundle.js')]).on('change', browserSync.reload);
});

/* WATCH */

gulp.task('watch', ['watch:scss', 'watch:images', 'watch:fonts', 'watch:webpack']);

gulp.task('watch:images', function(){
    gulp.watch(path.join(frontendImagesPath, '**','*'), ['images']);
});

gulp.task('watch:fonts', function(){
    gulp.watch(path.join(frontendFontsPath, '**','*'), ['fonts']);
});

gulp.task('watch:webpack', function() {
    webpack(webpackConfig).watch(100, onWebpackBuild());
});

gulp.task('watch:scss', function() {

    /* NEW UI */

    /* Watch all updates to vendor libraries */
    gulp.watch(path.join(frontendCssPath, 'new_ui', 'vendor', '**', '*.scss'), ['styles:newui:vendor']);

    /* watch updates to our code */
    gulp.watch([
        path.join(frontendCssPath, 'new_ui', '**', '*.scss'),
        path.join('!', frontendCssPath, 'new_ui', 'vendor', '**', '*.scss'),
        path.join('!', frontendCssPath, 'new_ui', 'common', '**', '*.scss')
        ], ['styles:newui:app']);

    /* update all when updating config and mixins */
    gulp.watch(path.join(frontendCssPath, 'new_ui', 'common', '**', '*.scss'), ['styles:newui']);

    gulp.watch(path.join(frontendCssPath, 'common', '**', '*.scss'), ['styles:other', 'styles:application', 'styles:instance_admin']);

    /* APPLICATION - application.scss application_vendor.scss */
    gulp.watch([
        path.join(frontendCssPath, '**', '*.scss'),
        path.join('!', frontendCssPath, 'new_ui','**', '*.scss'),
        path.join('!', frontendCssPath, 'instance_admin','**', '*.scss'),
        path.join('!', frontendCssPath, 'instance_wizard','**', '*.scss'),
        path.join('!', frontendCssPath, 'intel','**', '*.scss')
    ], ['styles:application']);

    /* INSTANCE ADMIN - application.scss application_vendor.scss */
    gulp.watch([
        path.join(frontendCssPath, '**', '*.scss'),
        path.join('!', frontendCssPath, 'new_ui','**', '*.scss')
    ], ['styles:instance_admin','styles:other']);

    /* INTEL - community.scss */
    gulp.watch([
        path.join(frontendCssPath, 'intel', '**', '*.scss'),
        path.join(frontendCssPath, 'community.scss')
    ], ['styles:intel']);
});

/* FONTS */
gulp.task('fonts', function(){
    return gulp.src(path.join(frontendFontsPath,'**','*.{eot,svg,ttf,woff,woff2}'))
        .pipe(gulp.dest( outputPath ));
});

gulp.task('fonts:dist', function(){
    return gulp.src(path.join(frontendFontsPath,'**','*.{eot,svg,ttf,woff,woff2}'))
        .pipe(gulp.dest( tmpAssetsPath ));
});

/* IMAGES */

gulp.task('images', function(){
    return gulp.src(path.join(frontendImagesPath, '**','*'))
        .pipe(gulp.dest(outputPath));
});


gulp.task('images:dist', function(){
    return gulp.src(path.join(frontendImagesPath, '**','*'))
        .pipe(gulpIf(gulpIf.isFile, cache(imagemin({
            progressive: true,
            interlaced: true,
            // don't remove IDs from SVGs, they are often used
            // as hooks for embedding and styling
            svgoPlugins: [{cleanupIDs: false}]
        }))
        .on('error', function (err) {
            throw new util.PluginError('images', err);
        })))
        .pipe(gulp.dest(tmpAssetsPath));
});

gulp.task('raygun', function() {
    return gulp.src([path.join(bower_components, 'raygun4js','dist','raygun.min.js'), path.join(bower_components, 'raygun4js','dist','raygun.min.js.map')])
        .pipe(gulp.dest(outputPath));
});

gulp.task('raygun:dist', function(){
    return gulp.src([path.join(bower_components, 'raygun4js','dist','raygun.min.js'), path.join(bower_components, 'raygun4js','dist','raygun.min.js.map')])
        .pipe(gulp.dest(tmpAssetsPath));
});


gulp.task('clean', del.bind(null, [path.join(__dirname, 'public', 'assets' ), path.join(__dirname,'tmp','assets')]));


/* DEFAULT TASK */

gulp.task('build', ['clean'], function(){
    return gulp.start(['fonts', 'images', 'styles', 'webpack', 'modernizr', 'ckeditor', 'raygun']);
});

gulp.task('default', ['build']);

/* DISTRIBUTION READY */

gulp.task('dist', ['clean'], function(){
    return gulp.start('manifest');
});

gulp.task('manifest', ['fonts:dist', 'images:dist', 'styles:dist', 'modernizr:dist', 'raygun:dist'], function(){
    gulp.src(path.join(tmpAssetsPath,'**','*'))
        .pipe(rev())
        .pipe(cssRevRewrite())
        .pipe(gulp.dest(outputPath))  // write rev'd assets to build dir
        .pipe(manifest())
        .pipe(gulp.dest(outputPath)); // write manifest to build dir

    return gulp.start('ckeditor');
});
