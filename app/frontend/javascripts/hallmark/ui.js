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

  UI.tabsClickSetHashOverride = function() {
    return $(document).on('click.hallmark.tabs', '[data-toggle="tab"]', function() {
      /*
       * By default, hash is not set when clicking tabs
       * We need hashes set but without scrolling to that area of the page
       */
      return history.replaceState({}, '', $(this).attr('href'));
    });
  };

  UI.activeTabFromAnchor = function() {
    var anchor, parent_match, parent_tab, tab;
    anchor = window.location.hash.substring(1);
    parent_tab = '';
    tab = '';
    if (anchor.length > 0) {
      parent_match = anchor.match(/([a-z]+)-([a-z]+)/i);
      if (parent_match) {
        parent_tab = $("[href='#" + parent_match[1] + "'][data-toggle=tab]");
      }
      tab = $("[href='#" + anchor + "'][data-toggle=tab]");
    } else {
      tab = $('[data-toggle=tab]:first');
    }
    if (parent_tab.length > 0) {
      parent_tab.click();
    }
    if (tab.length > 0) {
      return tab.click();
    }
  };

  UI.initialize = function() {
    this.equalize();
    this.nav();
    this.readmore();
    this.tabsStatic();
    this.tabsDynamic();
    this.activeTabFromAnchor();
    return this.tabsClickSetHashOverride();
  };

  return UI;
}();

module.exports = UI;
