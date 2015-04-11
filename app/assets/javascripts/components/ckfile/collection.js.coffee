class @Ckfile.Collection

  constructor : (container) ->
    @container = container
    @currentIndex = -1

  add : ->
    @currentIndex += 1

  update: (fileIndex, contents) ->
    @container.prepend(contents)

