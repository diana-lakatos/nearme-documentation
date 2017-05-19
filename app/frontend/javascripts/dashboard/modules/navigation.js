var Navigation;

require('jquery.cookie/jquery.cookie');

Navigation = function() {
  Navigation.prototype.cookie_name = 'navigation_visible';

  function Navigation() {
    this.body = $(document.body);
    this.main = $('main');
    this.createToggler();
    this.subnavigationItems();
    setTimeout(
      function() {
        return $('body').addClass('navigation-toggle-initialized');
      },
      50
    );
  }

  Navigation.prototype.createToggler = function() {
    var togglerClick;
    this.toggler = $('button.nav-toggler');
    togglerClick = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.toggleNavigation();
    };
    this.toggler.on('click', $.proxy(togglerClick, this));
    return $('.page-header-wrapper').prepend(this.toggler);
  };

  Navigation.prototype.saveState = function(state) {
    return $.cookie(this.cookie_name, state, { expires: 14, path: '/dashboard/' });
  };

  Navigation.prototype.readState = function() {
    return $.cookie(this.cookie_name);
  };

  Navigation.prototype.showNavigation = function() {
    this.body.addClass('navigation-visible');
    this.saveState(true);
    return this.main.on(
      'click.hidenavigation',
      function(_this) {
        return function(e) {
          e.preventDefault();
          return _this.hideNavigation();
        };
      }(this)
    );
  };

  Navigation.prototype.hideNavigation = function() {
    this.body.removeClass('navigation-visible');
    this.saveState(false);
    return this.main.off('click.hidenavigation');
  };

  Navigation.prototype.toggleNavigation = function() {
    if (this.body.hasClass('navigation-visible')) {
      return this.hideNavigation();
    }
    return this.showNavigation();
  };

  Navigation.prototype.subnavigationItems = function() {
    return $('.nav-primary').on('click', 'li > span', function(e) {
      return $(e.target).closest('li').toggleClass('selected');
    });
  };

  return Navigation;
}();

module.exports = Navigation;
