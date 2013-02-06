define(['backbone', 'views/locations/list', 'hbs!templates/app'],
function(Backbone, LocationsView, template) {
  var AppView = Backbone.View.extend({
    el: '#content',
    template: template,
    events: {},

    initialize: function() {
      this.views = {
        locations: LocationsView
      };

      locationsView = new LocationsView();
    },

    render: function() {
      this.$el.html(this.template());
      new this.contentView().render();
      return this;
    },

    setView: function(name) {
      switch (name) {
      case 'locations':
        this.contentView = this.views.locations;
        break;
      default:
        alert('view unknown');
      }
    }
  });

  return AppView;
});

