var PanelTabs;

PanelTabs = function() {
  function PanelTabs(el) {
    this.nav = $(el);
    this.triggers = this.nav.find('li');
    this.tabs = $('.panel-tab-container');
    this.bindEvents();
    this.activate(this.getInitialIndex());
  }

  PanelTabs.prototype.bindEvents = function() {
    return this.nav.on(
      'click',
      'a',
      function(_this) {
        return function(e) {
          var index;
          e.preventDefault();
          index = $(e.target).closest('li').index();
          return _this.activate(index);
          /*
         * true
         */
        };
      }(this)
    );
  };

  PanelTabs.prototype.activate = function(index) {
    this.triggers.removeClass('active').eq(index).addClass('active');
    return this.tabs.removeClass('active').eq(index).addClass('active');
  };

  PanelTabs.prototype.getInitialIndex = function() {
    var index;
    index = this.nav.find("li:has(a[href='" + window.location.hash + "'])").index();
    if (index < 0) {
      return 0;
    } else {
      return index;
    }
  };

  return PanelTabs;
}();

module.exports = PanelTabs;
