require({
  waitSeconds: 14,
  paths: {
    'scribe': '/assets/blog/admin/scribe_wysiwyg/scribe/scribe',
    'scribe-plugin-blockquote-command': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-blockquote-command/scribe-plugin-blockquote-command',
    'scribe-plugin-curly-quotes': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-curly-quotes/scribe-plugin-curly-quotes',
    'scribe-plugin-formatter-plain-text-convert-new-lines-to-html': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-formatter-plain-text-convert-new-lines-to-html/scribe-plugin-formatter-plain-text-convert-new-lines-to-html',
    'scribe-plugin-heading-command': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-heading-command/scribe-plugin-heading-command',
    'scribe-plugin-intelligent-unlink-command': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-intelligent-unlink-command/scribe-plugin-intelligent-unlink-command',
    'scribe-plugin-keyboard-shortcuts': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-keyboard-shortcuts/scribe-plugin-keyboard-shortcuts',
    'scribe-plugin-link-prompt-command': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-link-prompt-command/scribe-plugin-link-prompt-command',
    'scribe-plugin-sanitizer': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-sanitizer/scribe-plugin-sanitizer',
    'scribe-plugin-smart-lists': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-smart-lists/scribe-plugin-smart-lists',
    'scribe-plugin-toolbar': '/assets/blog/admin/scribe_wysiwyg/scribe-plugin-toolbar/scribe-plugin-toolbar'
  }
}, [
  'scribe',
  'scribe-plugin-blockquote-command',
  'scribe-plugin-curly-quotes',
  'scribe-plugin-formatter-plain-text-convert-new-lines-to-html',
  'scribe-plugin-heading-command',
  'scribe-plugin-intelligent-unlink-command',
  'scribe-plugin-keyboard-shortcuts',
  'scribe-plugin-link-prompt-command',
  'scribe-plugin-sanitizer',
  'scribe-plugin-smart-lists',
  'scribe-plugin-toolbar'
], function (
  Scribe,
  scribePluginBlockquoteCommand,
  scribePluginCurlyQuotes,
  scribePluginFormatterPlainTextConvertNewLinesToHtml,
  scribePluginHeadingCommand,
  scribePluginIntelligentUnlinkCommand,
  scribePluginKeyboardShortcuts,
  scribePluginLinkPromptCommand,
  scribePluginSanitizer,
  scribePluginSmartLists,
  scribePluginToolbar
) {

  'use strict';

  var prevElementSibling = (function(){
    var supported = !!document.body.previousElementSibling,
      prev = (supported) ? 'previousElementSibling' : 'previousSibling';

    return function(currentElement) {
      return currentElement[prev];
    };
  }());

  var nextElementSibling = (function(){
    var supported = !!document.getElementsByTagName('head')[0].nextElementSibling,
      next = (supported) ? 'nextElementSibling' : 'nextSibling';

    return function(currentElement) {
      return currentElement[next];
    };
  }());

  var scribeAll = document.querySelectorAll('.scribe');

  for (var i=0; i< scribeAll.length; i++) {
    var scribe = new Scribe(scribeAll[i], { allowBlockElements: true });

    scribe.on('content-changed', function(){
      nextElementSibling(this.el).querySelector('input[type=hidden]').value = this.getHTML()
    });

    /**
     * Plugins
     */

    scribe.use(scribePluginBlockquoteCommand());
    scribe.use(scribePluginHeadingCommand(2));
    scribe.use(scribePluginIntelligentUnlinkCommand());
    scribe.use(scribePluginLinkPromptCommand());
    scribe.use(scribePluginToolbar(prevElementSibling(scribeAll[i])));
    scribe.use(scribePluginSmartLists());
    scribe.use(scribePluginCurlyQuotes());

    // Formatters
    scribe.use(scribePluginSanitizer({
      tags: {
        p: {},
        br: {},
        b: {},
        strong: {},
        i: {},
        s: {},
        strike: {},
        blockquote: {},
        ol: {},
        ul: {},
        li: {},
        a: { href: true },
        h2: {}
      }
    }));
    scribe.use(scribePluginFormatterPlainTextConvertNewLinesToHtml());

    scribe.setContent(nextElementSibling(scribeAll[i]).querySelector('input[type=hidden]').value);
  }
});
