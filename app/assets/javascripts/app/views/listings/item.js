define(['jquery', 'backbone', 'hbs!templates/listings/item','bootstrap'], function($, Backbone, listingTemplate) {
  var ListingView = Backbone.View.extend({
    template: listingTemplate,
    initialize: function() {
      _.bindAll(this, 'render','_afterSave');
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
    },

    _afterSave: function(data){
      if (this.wasNew){
       // this.delegateEvents();
        this.wasNew = false;
       // this.render();
      }
      var elt = $(this.$el).find('.save-listing span');
      elt.text('Saved!');
      var initValue = elt.css('font-size');
      elt.animate({fontSize: "2em" }, 1500 );
      elt.animate({fontSize: initValue }, 1500, function(){elt.text('Save');});
    }


  });
  return ListingView;

});

