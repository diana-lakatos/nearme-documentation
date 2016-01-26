require('"imports?window=>{}!exports?window.CKEDITOR!ckeditor/ckeditor')
require('imports?CKEDITOR=>undefined!exports?CKEDITOR!./ckeditor/config')

module.exports = class CKEditorInitializer
  constructor: (wrapper)->
    @el = $(wrapper).find('textarea')
    @config =
    @initialize()

  initialize: ()->

    //<![CDATA[
(function() { if (typeof CKEDITOR != 'undefined') { if (CKEDITOR.instances['user_blog_post_content'] == undefined) { CKEDITOR.replace('user_blog_post_content', {"toolbar":"simple"}); } } else { setTimeout(arguments.callee, 50); } })();
//]]>



