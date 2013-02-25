PhotoView = Backbone.View.extend({
  tagName: 'li',
  className: 'photo-item',
  template: HandlebarsTemplates['app/templates/shared/photo'],
  initialize: function() {
    _.bindAll(this, 'render', 'trash');
    this._deleteTrigger = '.delete-photo'; // helper for testing
    this.listenTo(this.model, "change", this.render);
  },

  events: {
    "click .delete-photo": "trash"
  },

  render: function() {
    var data = this.model.toJSON();
    data.view_id = this.cid;
    data.cid = this.model.cid;
    this.$el.html(this.template(data));
    return this;
  },

  trash: function(event) {
    event.preventDefault();
    event.stopPropagation();
    var result = confirm("Are you sure you want to delete this Photo?");
    if (result === true) {
      this.model.trash();
      var self = this;
      this.$el.fadeOut(400, function() {
        self.remove();
      });
    }
  }

});

