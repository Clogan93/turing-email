describe "TuringEmailAppKeyboardHandler", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @keyboardHandler = new TuringEmailAppKeyboardHandler(TuringEmailApp)

  afterEach ->
    specStopTuringEmailApp()

  describe "#constructor", ->
    it "saves the app variable", ->
      expect(@keyboardHandler.app).toEqual(TuringEmailApp)

    handlers =
      "keydown": ["up", "down", "k", "j", "c", "r", "e", "y", "v"]
    
    for type, events of handlers
      it "handles the " + type + " events", ->
        expect(_.keys(@keyboardHandler.handlers[type]).sort()).toEqual(events.sort())      

  describe "#start", ->
      beforeEach ->
        @bindKeysStub = sinon.stub(@keyboardHandler, "bindKeys")
        @keyboardHandler.start()
        
      afterEach ->
        @bindKeysStub.restore()
        
      it "binds the keys", ->
        expect(@bindKeysStub).toHaveBeenCalled()

  describe "#stop", ->
    beforeEach ->
      @unbindKeysStub = sinon.stub(@keyboardHandler, "unbindKeys")
      @keyboardHandler.stop()

    afterEach ->
      @unbindKeysStub.restore()

    it "unbinds the keys", ->
      expect(@unbindKeysStub).toHaveBeenCalled()
        
  describe "#bindKeys", ->
    beforeEach ->
      @keyboardHandler.bindKeys()

    it "binds the handlers", ->
      # TODO figureout how to test - jquery hotkeys is messingit up because it intercepts the handler
      #for type, typeHandlers of @keyboardHandler.handlers
        #for keys, callback of typeHandlers
          #expect($(document)).toHandleWith(type, callback)

  describe "#unbindKeys", ->
    beforeEach ->
      @keyboardHandler.bindKeys()
      @keyboardHandler.unbindKeys()

    it "unbinds the events", ->
      # TODO figureout how to test - jquery hotkeys is messingit up because it intercepts the handler
      #for type, typeHandlers of @keyboardHandler.handlers
        #for keys, callback of typeHandlers
          #expect($(document)).not.toHandleWith(type, callback)
    
  describe "after start", ->
    beforeEach ->
      @keyboardHandler.start()
      
    afterEach ->
      @keyboardHandler.stop()
      
    describe "#moveSelectionUp", ->
      # TODO figure out how to test preventDefault - spyOnEvent isn't working
      
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
        @event.which = $.ui.keyCode.UP

        @moveSelectionUpStub = sinon.stub(@keyboardHandler.app.views.emailThreadsListView, "moveSelectionUp")

        @keyboardHandler.moveSelectionUp(@event)

      afterEach ->
        @moveSelectionUpStub.restore()
        
      it "moves the selection up on the email threads list view", ->
        expect(@moveSelectionUpStub).toHaveBeenCalled()

    describe "#moveSelectionDown", ->
      # TODO figure out how to test preventDefault - spyOnEvent isn't working
      
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
        @event.which = $.ui.keyCode.DOWN

        @moveSelectionDownStub = sinon.stub(@keyboardHandler.app.views.emailThreadsListView, "moveSelectionDown")

        @keyboardHandler.moveSelectionDown(@event)

      afterEach ->
        @moveSelectionDownStub.restore()

      it "moves the selection down on the email threads list view", ->
        expect(@moveSelectionDownStub).toHaveBeenCalled()

    describe "#showCompose", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
  
        @loadEmptyStub = sinon.stub(@keyboardHandler.app.views.composeView, "loadEmpty")
        @showStub = sinon.stub(@keyboardHandler.app.views.composeView, "show")
  
        @keyboardHandler.showCompose(@event)
  
      afterEach ->
        @loadEmptyStub.restore()
        @showStub.restore()
  
      it "shows an empty compose view", ->
        expect(@loadEmptyStub).toHaveBeenCalled()
        expect(@showStub).toHaveBeenCalled()

    describe "#showReply", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler

        @replyClickedStub = sinon.stub(@keyboardHandler.app, "replyClicked")
  
        @keyboardHandler.showReply(@event)
  
      afterEach ->
        @replyClickedStub.restore()
  
      it "show the reply email view", ->
        expect(@replyClickedStub).toHaveBeenCalled()

    describe "#archiveEmail", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
  
        @archiveClickedStub = sinon.stub(@keyboardHandler.app, "archiveClicked")
  
        @keyboardHandler.archiveEmail(@event)

      afterEach ->
        @archiveClickedStub.restore()
  
      it "calls the archive emails handler", ->
        expect(@archiveClickedStub).toHaveBeenCalled()

    describe "#showMoveToFolderMenu", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
  
        @showMoveToFolderMenuStub = sinon.stub(@keyboardHandler.app.views.toolbarView, "showMoveToFolderMenu")
  
        @keyboardHandler.showMoveToFolderMenu(@event)
  
      afterEach ->
        @showMoveToFolderMenuStub.restore()
  
      it "shows the move to folder menu", ->
        expect(@showMoveToFolderMenuStub).toHaveBeenCalled()
