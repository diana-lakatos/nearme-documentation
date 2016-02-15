var
    path = require('path');

module.exports = function(gulp, config) {


    gulp.task('watch:images', function(){
        gulp.watch(path.join(config.paths.images, '**','*'), ['images']);
    });

    gulp.task('watch:fonts', function(){
        gulp.watch(path.join(config.paths.fonts, '**','*'), ['fonts']);
    });

    gulp.task('watch:scss', function() {

        /* NEW UI */

        /* Watch all updates to vendor libraries */
        gulp.watch(path.join(config.paths.stylesheets, 'new_ui', 'vendor', '**', '*.scss'), ['styles:newui:vendor']);

        /* watch updates to our code */
        gulp.watch([
            path.join(config.paths.stylesheets, 'new_ui', '**', '*.scss'),
            path.join('!', config.paths.stylesheets, 'new_ui', 'vendor', '**', '*.scss'),
            path.join('!', config.paths.stylesheets, 'new_ui', 'common', '**', '*.scss')
            ], ['styles:newui:app']);

        /* update all when updating config and mixins */
        gulp.watch(path.join(config.paths.stylesheets, 'new_ui', 'common', '**', '*.scss'), ['styles:newui']);

        gulp.watch(path.join(config.paths.stylesheets, 'common', '**', '*.scss'), ['styles:other', 'styles:application', 'styles:instance_admin']);

        /* APPLICATION - application.scss application_vendor.scss */
        gulp.watch([
            path.join(config.paths.stylesheets, '**', '*.scss'),
            path.join('!', config.paths.stylesheets, 'new_ui','**', '*.scss'),
            path.join('!', config.paths.stylesheets, 'instance_admin','**', '*.scss'),
            path.join('!', config.paths.stylesheets, 'instance_wizard','**', '*.scss'),
            path.join('!', config.paths.stylesheets, 'intel','**', '*.scss')
        ], ['styles:application']);

        /* INSTANCE ADMIN - application.scss application_vendor.scss */
        gulp.watch([
            path.join(config.paths.stylesheets, '**', '*.scss'),
            path.join('!', config.paths.stylesheets, 'new_ui','**', '*.scss')
        ], ['styles:instance_admin','styles:other']);

        /* INTEL - community.scss */
        gulp.watch([
            path.join(config.paths.stylesheets, 'intel', '**', '*.scss'),
            path.join(config.paths.stylesheets, 'community.scss')
        ], ['styles:intel']);
    });

    gulp.task('watch', ['watch:scss', 'watch:images', 'watch:fonts', 'watch:webpack']);
};
