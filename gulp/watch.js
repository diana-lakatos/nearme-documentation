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
            '!new_ui/**/*.scss',
            '!intel/**/*.scss',
            '!community.scss',
            '!admin/**/*.scss',
            '!admin.scss',
            '!shared/**/*.scss'
        ], { cwd: config.paths.stylesheets }, ['styles:application', 'styles:instance_admin','styles:other']);

        /* NEW UI */

        /* Watch all updates to vendor libraries */
        gulp.watch('new_ui/vendor/**/*.scss', { cwd: config.paths.stylesheets }, ['styles:newui:vendor']);

        /* watch updates to our code */
        gulp.watch([
            'new_ui/**/*.scss',
            '!new_ui/vendor/**/*.scss',
            '!new_ui/common/**/*.scss'
        ], { cwd: config.paths.stylesheets } ['styles:newui:app']);

        /* update all when updating config and mixins */
        gulp.watch('new_ui/common/**/*.scss', { cwd: config.paths.stylesheets }, ['styles:newui']);

        /* INTEL - community.scss */
        gulp.watch([
            'intel/**/*.scss',
            'community.scss'
        ], { cwd: config.paths.stylesheets }, ['styles:intel']);

        gulp.watch([
            'shared/**/*.scss'
        ], { cwd: config.paths.stylesheets }, ['styles:application', 'styles:newui']);
    });

    gulp.task('watch', ['watch:scss', 'watch:images', 'watch:fonts', 'watch:webpack', 'watch:lint']);
};
