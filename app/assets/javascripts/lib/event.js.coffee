# Helper for observing and notifying of events on an object
DNM.Event =

  # Observe an event on an object
  observe: (object, event, callback) ->
    @_getObservers(object, event).push callback

  # Notify observers of an event
  notify: (object, event, args = []) ->
    for callback in @_getObservers(object, event)
      callback.apply(object, args)

  # Helper method for getting and initializing the observers list for an object
  _getObservers: (object, event = null) ->
    if event
      @_getObservers(object)[event] ||= []
    else
      object.__observers ||= {}


