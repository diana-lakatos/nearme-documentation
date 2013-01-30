define(['jquery', 'backbone', 'Collections/listing', 'Models/listing', 'Views/listings/item', 'hbs!templates/locations/item'], function($, Backbone, ListingCollection, ListingModel, ListingView, locationTemplate) {
  var LocationView = Backbone.View.extend({
    template: locationTemplate,
    initialize: function() {
      _.bindAll(this, 'render', 'addAll', 'addOne','trash', '_afterSave');
      this.listingCollection = new ListingCollection(this.model.get('listings'));
      var self = this;
    },

    events: {
      "click .save-location": "save",
      "click .delete-location": "trash",
      "click .add-listing": "createListing",
      "keyup input#name": "nameChanged"
    },

    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.addAll();
      if (this.model.isNew()) {
        $('.add-listing', this.$el).hide();
      }
      return this;
    },

    addAll: function() {
      this.listingCollection.each(this.addOne);
    },

    addOne: function(listing) {
      var view = new ListingView({
        model: listing
      });
      var hookElt = '#location-' + this.model.id + '-listings-holder';
      var content = view.render().el;
      $(this.$el).find(hookElt).append(content);
      if (listing.isNew()) {
        $(".listing-content", $(content)).collapse('show'); // expend the listing container
      }
    },

    createListing: function() {
      event.preventDefault();
      event.stopPropagation();
      var listing = new ListingModel({
        name: 'New listing',
        location_id: this.model.id
      });
      this.addOne(listing);
    },

    nameChanged: function(event) {
      $('.location-header[data-location-id=' + this.model.id + ']', this.$el).text($(event.target).val());
    },

    save: function() {
      event.preventDefault();
      event.stopPropagation();
      this.justCreated = this.model.isNew();
      var arr = this.$el.find('.edit_location').serializeArray();
      var data = _(arr).reduce(function(acc, field) {
        if (acc[field.name]) { // deal with array checkbox type like amenities_ids[]
          if (!_.isArray(acc[field.name])) {
            acc[field.name] = [acc[field.name]];
          }
          acc[field.name].push(field.value);
        } else {
          acc[field.name] = field.value;
        }
        return acc;
      }, {});
      this.model.save(data, {
        success: this._afterSave
      });
    },

    trash: function(event) {
      event.preventDefault();
      event.stopPropagation();
      var result = confirm("Are you sure you want to delete this Space?");
      if (result === true) {
        this.model.trash();
        this.$el.fadeOut(400, function() {
          self.remove();
        });
      }
    },

    _afterSave: function(data) {
      var elt = $(this.$el).find('.save-location span');
      elt.text('Saved!');
      var initValue = elt.css('font-size');
      elt.animate({
        fontSize: "2em"
      }, 1500);
      elt.animate({
        fontSize: initValue
      }, 1500, function() {
        elt.text('Save');
      });

      if (this.justCreated) {
        this.justCreated = false;
        this.render();
        $('.location-content', this.$el).collapse('show');
      }
    }
  });
  return LocationView;

});

