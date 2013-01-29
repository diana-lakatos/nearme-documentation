define(['jquery', 'backbone','Collections/listing', 'Models/listing', 'Views/listings/item', 'hbs!templates/locations/item'], function($, Backbone, ListingCollection, ListingModel, ListingView, locationTemplate) {
  var LocationView = Backbone.View.extend({
    template: locationTemplate,
    initialize: function() {
      _.bindAll(this, 'render','addAll','addOne','_afterSave');
      this.listingCollection = new ListingCollection(this.model.get('listings'));
      var self = this;
    },

    events: {
      "click header.location": "toggleAction",
      "click .save": "save",
      "click .delete": "trash",
      "click .add-listing": "createListing",
      "keyup input#name": "nameChanged"

    },

    render: function() {
      this.setElement(this.template(this.model.toJSON()));
      this.addAll();
      if (this.model.isNew()){
        $('.add-listing',this.$el).hide();
      }
      return this;
    },

    addAll: function() {
      this.listingCollection.each(this.addOne);
    },

    addOne: function(listing) {
        var view = new ListingView({model: listing});
        var hookElt = '#location-' + this.model.id + '-listings-holder';
        $(this.$el).find(hookElt).append(view.render().el);
      },

    toggleAction: function(event) {
      var field = $(event.currentTarget);
      $(".actions", field).toggle();
    },

    createListing: function() {
      event.preventDefault();
      event.stopPropagation();
      var listing = new ListingModel({name: 'New listing'});
      //var listing = new ListingModel();
      this.addOne(listing);
    },

    nameChanged: function(event){
      $('.location-header[data-location-id='+ this.model.id +']', this.$el).text($(event.target).val());
    },


    save: function() {
      event.preventDefault();
      event.stopPropagation();
      this.wasNew = this.model.isNew();
      var arr = this.$el.find('.edit_location').serializeArray();
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
      var result = confirm("Are you sure you want to delete this Space?");
      if (result === true) {
        this.model.trash();
        this.$el.fadeOut();
      }
    },

    _afterSave: function(data){
      if (this.wasNew){
        this.delegateEvents();
        this.wasNew = false;
        this.render();
      }
    }
  });
  return LocationView;

});
