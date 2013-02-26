AppView = Backbone.View.extend({
  el: '#content',
  template: HandlebarsTemplates['app/templates/app'],
  events: {},

  initialize: function() {
    this.views = {
      locations: LocationsView
    };
    locationsView = new LocationsView();
    this.initializeTooltips();
  },

  render: function() {
    this.$el.html(this.template());
    new this.contentView().render();
    return this;
  },

  initializeTooltips: function(){
    this.$el.tooltip({selector:'[rel=tooltip]',placement: 'top'});
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
