window.backbone = class
  @spy: (object, event) ->
    return new spy(object, event)
    
  class spy
    constructor: (@object, @event) ->
      @spy = sinon.spy()
      object.on(@event, @spy)

    restore: ->
      @object.off(@event, @spy)
