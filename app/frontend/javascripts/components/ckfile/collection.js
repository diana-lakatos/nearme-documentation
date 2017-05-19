var CkfileCollection;

CkfileCollection = function() {
  function CkfileCollection(container) {
    this.container = container;
    this.currentIndex = -1;
  }

  CkfileCollection.prototype.add = function() {
    return this.currentIndex += 1;
  };

  CkfileCollection.prototype.update = function(fileIndex, contents, append) {
    if (append == null) {
      append = false;
    }
    if (append) {
      return this.container.append(contents);
    } else {
      return this.container.prepend(contents);
    }
  };

  return CkfileCollection;
}();

module.exports = CkfileCollection;
