define(['jquery', 'backbone', 'hbs!templates/listings/item'], function($, Backbone, listingTemplate) {
  var ListingView = Backbone.View.extend({
    template: listingTemplate,
    initialize: function() {
      _.bindAll(this, 'render');
      this.model.set('ref_id', this.options.refId);
    },

    events: {
      "click header.listing": "toggleAction",
      "click .save-listing": "save",
      "click .delete-listing": "trash",
      "keyup input#listing_name": "nameChanged"
    },

    render: function() {
      this.setElement(this.template(this.model.toJSON()));
      return this;
    },

    toggleAction: function(event) {
      var field = $(event.currentTarget);
      $(".actions", field).toggle();
    },

    nameChanged: function(event){
      $('.listing-header[data-listing-id='+ this.model.id +']', this.$el).text($(event.target).val());
    },

   save: function() {
      event.preventDefault();
      event.stopPropagation();
      this.wasNew = this.model.isNew();
      var arr = this.$el.find('.edit_listing').serializeArray();
      var data = _(arr).reduce(function(acc, field) {
        if (acc[field.name]) { // deal with array checkbox type like amenities_ids[]
          if (!_.isArray(acc[field.name])) {
            acc[field.name] = [acc[field.name]];
          }
          acc[field.name].push(field.value);
        }
        else {
          acc[field.name] = field.value;
        }
        return acc;
      }, {});
      console.log(data);
      //this.model.save({name: this.$el.find('#location_name').val()});
      this.model.save(data, {success: this._afterSave});
    },

    trash: function(event) {
      event.preventDefault();
      event.stopPropagation();
      var result = confirm("Are you sure you want to delete this Listing?");
      if (result === true) {
        this.model.trash();
        this.$el.fadeOut();
      }
    }

  });
  return ListingView;

});

