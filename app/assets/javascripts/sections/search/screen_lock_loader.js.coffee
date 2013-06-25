# Class for displaying ajax loader locking other parts of the screen with transaparent div.
class Search.ScreenLockLoader
  lockerClass: 'screen-locker'

  constructor: (@containerCallback)->
    @showed = false

  show: ->
    return if @showed
    @containerCallback().show()
    $('#content').append(@locker())
    @showed = true

  hide: ->
    @containerCallback().hide()
    @lockerElement.remove()
    @showed = false

  showWithoutLocker: ->
    @containerCallback().show()

  locker: ->
    @lockerElement = $('<div>').addClass(@lockerClass)
