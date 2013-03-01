ListingModel = Backbone.Model.extend({
  defaults: {
      'location_id': null,
      'name': null,
      'description': null,
      'quantity': null,
      'listing_type_id': null,
      'availability_template_id': 'M-F9-5',
      'defer_availability_rules': 0,
      'availability_rules_attributes': [
          {
              "day": 1,
              "day_name": "Monday",
              "id": null,
              "open_time": "9:0",
              "close_time": "17:0"
          },
          {
              "day": 2,
              "day_name": "Tuesday",
              "id": null,
              "open_time": "9:0",
              "close_time": "17:0"
          },
          {
              "day": 3,
              "day_name": "Wednesday",
              "id": null,
              "open_time": "9:0",
              "close_time": "17:0"
          },
          {
              "day": 4,
              "day_name": "Thursday",
              "id": null,
              "open_time": "9:0",
              "close_time": "17:0"
          },
          {
              "day": 5,
              "day_name": "Friday",
              "id": null,
              "open_time": "9:0",
              "close_time": "17:0"
          },
          {
              "day": 6,
              "day_name": "Saturday",
              "id": null,
              "open_time": null,
              "close_time": null
          },
          {
              "day": 0,
              "day_name": "Sunday",
              "id": null,
              "open_time": null,
              "close_time": null
          }
      ]

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
