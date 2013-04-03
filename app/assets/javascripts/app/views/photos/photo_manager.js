PhotoManagerView = Backbone.View.extend({
  template: HandlebarsTemplates['app/templates/shared/photoManager'],
  initialize: function() {
    _.bindAll(this, 'render', 'addAll', 'addOne', '_findModelByFilename');
    this._childContainer = '.gallery';
    this.ref_type = this.options.ref_type;
    this.getRefId = this.options.getRefId;
    this.collection = this.options.collection;
  },

  //required by backend to create relation with parent element
  _getRefData: function() {
    return [{
      name: 'content_type',
      value: this.ref_type
    }, {
      name: 'content_id',
      value: this.getRefId() // can be null or not depending if parent exist.
    }, {
      name: 'token',
      value: $('meta[name="auth-token"]').attr('content')
    }];

  },

  render: function() {
    this.$el.html(this.template());
    this.addAll();
    this.initUploader();
    return this;
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
    var csrf_token = $('meta[name="csrf-token"]').attr('content');
    // Initialize the jQuery File Upload widget:
    $('.fileupload', this.$el).fileupload({
      headers: {
        'Authorization': token,
        'X-CSRF-Token': csrf_token
      },
      url: '/v1/photos?photouploader=true',
      paramName: 'image',
      add: function(e, data) {
        var photoModel = new PhotoModel();
        photoModel.set({filename: data.files[0].name});
        self.collection.add(photoModel, {silent:true});
        self.addOne(photoModel);
        data.formData = self._getRefData();
        data.submit();
      },
      done: function(e, data) {
        var photoModel = self._findModelByFilename(data.files[0].name);
        var result_to_parse;
        if($.browser.msie){
          result_to_parse = $('pre', data.result).text();
        }
        else{
          result_to_parse = data.result;
        }
        photoModel.set(jQuery.parseJSON(result_to_parse));
      },
      progress: function(e, data) {
        var photoModel = self._findModelByFilename(data.files[0].name);
        var progress = parseInt(data.loaded / data.total * 100, 10);
        var $uiProgress = $('#'+ photoModel.cid +'.progress', self.$el);
        $uiProgress.find('.bar').css('width', progress + '%');
        if (progress == 100) {
          $uiProgress.fadeOut();
          $('#' + photoModel.cid + 'loading.loading', self.$el).fadeIn();
        }
      }

    });

  },

  _findModelByFilename: function(filename) {
    return this.collection.where({filename: filename})[0];
  }


});

