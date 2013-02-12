define(['jquery', 'backbone', 'Collections/listing', 'Models/listing', 'Views/listings/item', 'hbs!templates/locations/item', 'hbs!templates/shared/errors',  'location_finder'], function($, Backbone, ListingCollection, ListingModel, ListingView, locationTemplate, errorsTemplate) {
  var LocationView = Backbone.View.extend({
    template: locationTemplate,
    initialize: function() {
      _.bindAll(this, 'render', 'addAll', 'addOne','trash', 'toggleCmd', '_afterSave', '_showError');
      this.listingCollection = new ListingCollection(this.model.get('listings'));
      this._childContainer = '.listings-holder';
      this._addTrigger = '.add-listing'; // helper for testing
      this._deleteTrigger = '.delete-location'; // helper for testing
    },

    events: {
      "click .save-location": "save",
      "click .delete-location": "trash",
      "click .add-listing": "createListing",
      "keyup input#name": "nameChanged",
      "keyup #address": "valChanged",
      "click .edit_location .availability-rules input[type=radio]" : "availabilityChanged",
      "click .closed": "updateClosedState"
    },

    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.addAll();
      this.toggleCmd();
      new DNM.LocationFinder($('form#edit_location_'+ this._getId(), this.$el));
      return this;
    },

    addAll: function() {
      this.thumbnail_url = this.getThumbnailUrl();
      this.listingCollection.each(this.addOne);
    },

    addOne: function(listing) {
      var view = new ListingView({
        model: listing,
        thumbnail_url: this.thumbnail_url
      });
      var content = view.render().el;
      $(this.$el).find(this._childContainer).append(content);
      if (listing.isNew()) {
        $(".listing-content", $(content)).collapse('show'); // expend the listing container
        $("input#listing_name", $(content)).focus();
      }
    },

    getThumbnailUrl: function() {
      var params = $.param({sensor: false, size: '64x64', location: this.model.get('latitude')+ ',' + this.model.get('longitude')});
      return "http://maps.googleapis.com/maps/api/streetview?" + params;
    },

    createListing: function(event) {
      event.preventDefault();
      event.stopPropagation();
      var listing = new ListingModel({
        location_id: this.model.id
      });
      this.addOne(listing);
    },

    nameChanged: function(event) {
      var target = $(event.target);
      target.closest('section.location').find('span.location-header').text(target.val());
    },

    valChanged: function(event) {
      var viewTarget = null;
      $('#formatted_address', this.$el).val($(event.target).val());
    },

    availabilityChanged: function(event) {
      var target = event.target;
      var customRules = $(target).closest('.availability-rules').find('.custom-availability-rules');
      if(target.id === "availability_rules_custom") {
        customRules.show();
      } else {
        customRules.hide();
      }
    },

    updateClosedState: function(event) {
      var checkbox = $(event.target);
      var times = checkbox.closest('.day').find('.open-time select, .close-time select');
      if (checkbox.is(':checked')) {
        times.hide();
      }
      else {
        times.show();
      }
    },
    toggleCmd: function(event) {
      var target = $('.add-listing', this.$el);
      if (!this.model.isNew()) {
        target.fadeIn().css('display','inline-block');// using show() renders display "inline" instead of "inline-block"
      } else {
        target.hide();
      }
    },

    save: function(event) {
      event.preventDefault();
      event.stopPropagation();
      this.justCreated = this.model.isNew();

      var data = this._serializeData(this.$el.find('.edit_location'));
      this.model.save(data, {
        success: this._afterSave,
        error: this._showError
      });
    },

    trash: function(event) {
      event.preventDefault();
      event.stopPropagation();
      var result = confirm("Are you sure you want to delete this Space?");
      if (result === true) {
        this.model.trash();
        var self = this;
        this.$el.fadeOut(400, function() {
          self.remove();
        });
      }
    },

    _afterSave: function(data) {
      var elt = $(this.$el).find('.save-location span');
      elt.animate({
        opacity: 0.2
      }, 500, function() {
        elt.text('Saved!');
      });
      elt.animate({
        opacity: 1
      });
      elt.animate({
        opacity: 0.2
      }, 500, function() {
        elt.text('Save');
      });
      elt.animate({
        opacity: 1
      }, 1500 );

      if (this.justCreated) {
        this.justCreated = false;
        this.toggleCmd();
      }
    },

    _showError: function(data){
      var msg = $.parseJSON(data.responseText).errors.join(", ");
      var content = errorsTemplate({msg:msg});
      $('.action', this.$el.find('#location-'+ this._getId() +'-details-holder')).prepend(content);
      $('.alert-error', this.$el).fadeIn();
    },

    _getId: function(){
      return  !this.model.isNew()? this.model.id : '';
    },

    _serializeData: function($fragment) {
      var arr = $fragment.serializeArray();
      var pattern = new RegExp(/([a-z_]+)\[([^\]]+)\]\[([^\]]+)\]/); // match my_attributes_array[1][id]

      var data = _(arr).reduce(function(acc, field) {
        if (acc[field.name] && !pattern.test(field.name) ) { // deal with array checkbox type like amenities_ids[]
          if (!_.isArray(acc[field.name])) {
            acc[field.name] = [acc[field.name]];
          }
          acc[field.name].push(field.value);
        }else if (pattern.test(field.name)) { // deal with  nested object
          var split = field.name.match(pattern);
          var name = split[1];
          var index = split[2];
          var param = split[3];

          if (!acc[name]) {
            acc[name] = {};
          }
          if (!acc[name][index]) {
            acc[name][index] = {};
          }
          acc[name][index][param] = field.value;
        }

        else {
          acc[field.name] = field.value;
        }
        return acc;
      }, {});

      return data;
    }

  });
  return LocationView;

});

