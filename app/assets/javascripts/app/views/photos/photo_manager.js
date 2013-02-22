PhotoManagerView = Backbone.View.extend({
  template: HandlebarsTemplates['app/templates/shared/photoManager'],
  initialize: function() {
    _.bindAll(this, 'render', 'addAll', 'addOne');
    this._childContainer = '.gallery';
    this.ref_type = this.options.ref_type;
    this.getRefId = this.options.getRefId;
    this.collection = this.options.collection;
  },

  events: {
    'click .fileinput_button': 'showFileSelector'
  },

  //required by backend to create relation with parent element
  _getRefData: function() {
    return [{
      name: 'content_type',
      value: this.ref_type
    }, {
      name: 'content_id',
      value: this.getRefId() // can be null or not depending if parent exist.
    }];

  },

  render: function() {
    this.$el.html(this.template());
    this.addAll();
    this.initUploader();
    return this;
  },

  showFileSelector: function() {
    event.preventDefault();
    event.stopPropagation();
  },

  addAll: function() {
    this.collection.each(this.addOne);
  },

  addOne: function(photo) {
    var view = new PhotoView({
      model: photo
    });
    var content = view.render().el;
    $(this.$el).find(this._childContainer).append(content);
  },

  initUploader: function() {
    var self = this;
    var token = $('meta[name="auth-token"]').attr('content');
    // Initialize the jQuery File Upload widget:
    $('.fileupload', this.$el).fileupload({
      headers: {
        'Authorization': token
      },
      dataType: 'json',
      url: '/v1/photos',
      paramName: 'image',
      add: function(e, data) {
        data.formData = self._getRefData();
        data.submit();
      },
      done: function(e, data) {
        self.addOne(new PhotoModel(data.result));
      },
      progress: function(e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $('.progress .bar', self.$el).css('width', progress + '%');
      },

      progressall: function(e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $('.progressall .bar', self.$el).css('width', progress + '%');
      }

    });

  }

});

