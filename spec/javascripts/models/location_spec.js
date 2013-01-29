//=require require
//=require config
/*define(['models/Location'], function(Location) {*/

//return describe('Model :: Location', function() {
//describe('Model properties', function() {
//it('should have a name', function() {
//var name_value = "San Fransisco";
//var locationModel = new Location({
//name: name_value
//});
//expect(locationModel.get("name")).toEqual(name_value);
//});
//});
//});
/*});*/


describe('Model properties', function() {

  define(['models/Location'], function(Location) {
    it('should have a name', function() {
      var name_value = "San Fransisco";
      var locationModel = new Location({
        name: name_value
      });
      expect(locationModel.get("name")).toEqual(name_value);
    });
  });
});

