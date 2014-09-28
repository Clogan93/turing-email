class backbone
  class spy
    constructor: (@object, @event) ->
      @callCount = 0

      @object.listenTo(@event, @callback, this)
    
    callback: ->
      @callCount++
