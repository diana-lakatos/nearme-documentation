# Whole purpose of this file is to enable custom selects and date pickers in schedule
class @DNM.InstanceAdmin.Schedule
  constructor: (el)->
    @container = $(el)
    @initialize()
    @bindEvents()

  initialize: ->


  bindEvents: ->



$('.transactable-schedule-container').each (index, item)=>
  return new @DNM.InstanceAdmin.Schedule(item);
