var UI;

require('./vendor/vequalize');

require('imports?this=>window!./vendor/tinynav');

UI = function() {
  function UI() {}

  /*
   * makes elements with data-equalize attribute the same height
   */
  UI.equalize = function() {
    var prop;
    prop = !document.addEventListener ? 'height' : 'outerHeight';
    return $('[data-equalize]').vEqualize({ height: prop });
  };

  /*
   * toggle navigation visibility
   */
  UI.nav = function() {
    var body;
    body = $('body');
    return $('[data-nav]').on('click', function(event) {
      event.preventDefault();
      return body.toggleClass('is-nav');
    });
  };

  /*
   * expand read more sections
   */
  UI.readmore = function() {
    return $('body').on('click', '.readmore-a', function(event) {
      event.preventDefault();
      return $(this).addClass('is-active');
    });
  };

  /*
   * toggles visibility of the comment form
   */
  UI.toggleCommentForm = function() {
    return $('body').on('click', '[data-comment]', function(event) {
      event.preventDefault();
      return $(this).closest('footer').find('> .comment').toggleClass('is-active');
    });
  };

  /*
   * init tinyNav for tabs navigation
   */
  UI.tabsStatic = function() {
    return $('.tabs-a ul:not(.nav-tabs)').tinyNav({ active: 'is-active' });
  };

  UI.tabsDynamic = function() {
    return $('.tabs-a ul.nav-tabs').each(function() {
      var list, select, tabs;
      list = $(this);
      tabs = list.find('[role="tab"]');
      select = $('<select/>');
      tabs.each(function() {
        var option;
        option = $('<option>', { value: $(this).attr('href'), text: $(this).text() });
        return option.appendTo(select);
      });
      select.on('change', function() {
        var href;
        href = $(this).val();
        return tabs.filter('[href="' + href + '"]').tab('show');
      });
      tabs.on('click', function() {
        var href;
        href = $(this).attr('href');
        return select.val(href);
      });
      return list.after(select);
    });
  };

  UI.activeTabFromAnchor = function() {
    var anchor, tab;
    anchor = window.location.hash.substring(1);
    tab = '';
    if (anchor.length > 0) {
      tab = $("[href='#" + anchor + "'][data-toggle=tab]");
    } else {
      tab = $('[data-toggle=tab]:first');
    }
    if (tab.length > 0) {
      return tab.click();
    }
  };

  UI.initialize = function() {
    this.equalize();
    this.nav();
    this.readmore();
    this.toggleCommentForm();
    this.tabsStatic();
    this.tabsDynamic();
    return this.activeTabFromAnchor();
  };

  return UI;
}();

module.exports = UI;
