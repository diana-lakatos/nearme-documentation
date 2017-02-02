module.exports = class CkfileCollection

  constructor: (container) ->
    @container = container
    @currentIndex = -1

  add : ->
    @currentIndex += 1

  update: (fileIndex, contents, append = false) ->
    if append
      @container.append(contents)
    else
      @container.prepend(contents)

