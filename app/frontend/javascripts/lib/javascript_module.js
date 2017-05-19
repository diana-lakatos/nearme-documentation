var JavascriptModule, moduleKeywords;

moduleKeywords = [ 'extended', 'included' ];

JavascriptModule = function() {
  function JavascriptModule() {}

  JavascriptModule.extend = function(obj) {
    var key, value;
    for (key in obj) {
      value = obj[key];
      if (moduleKeywords.indexOf(key) < 0) {
        this[key] = value;
      }
    }
    if (obj.extended) {
      obj.extended.apply(this);
    }
    return this;
  };

  JavascriptModule.include = function(obj) {
    var key, value;
    for (key in obj) {
      value = obj[key];

      /*
       * Assign properties to the prototype
       */
      if (moduleKeywords.indexOf(key) < 0) {
        this.prototype[key] = value;
      }
    }
    if (obj.included) {
      obj.included.apply(this);
    }
    return this;
  };

  return JavascriptModule;
}();

module.exports = JavascriptModule;
