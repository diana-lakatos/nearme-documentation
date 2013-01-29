define(['backbone'], function(Backbone) {
  var ListingModel = Backbone.Model.extend({
    initialize: function(attributes) {},

    defaults: {
      ref_id: null
    },

    url: function() {
      var base = '/v1/listings';
      if (this.isNew()) {
        return base;
      }
      return base + (base.charAt(base.length - 1) == '/' ? '' : '/') + this.id;
    },

    trash: function() {
      this.destroy({
        success: function(model, response) {
          //TODO-Add notify on destroy alert("destroy success");
          return true;
        },
        error: function(model, response) {
          alert("destroy error");
          //TODO-Add notify on destroy alert("destroy error");
          return false;
        }
      });
    }

  });
  return ListingModel;
});

