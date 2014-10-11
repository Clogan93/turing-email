describe "TuringEmailAppKeyboardHandler", ->
  beforeEach ->
    specStartTuringEmailApp()
    
    @keyboardHandler = new TuringEmailAppKeyboardHandler(TuringEmailApp)

    @handlers =
      "keydown": @keyboardHandler.onKeyDown
    
  afterEach ->
    specStopTuringEmailApp()

  describe "#constructor", ->
    it "saves the app variable", ->
      expect(@keyboardHandler.app).toEqual(TuringEmailApp)
    
    it "handles the expected events", ->
      expect(@keyboardHandler.handlers).toEqual(@handlers)      

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
      
    it "binds the events", ->
      for event, callback of @handlers
        expect($(document)).toHandleWith(event, callback)

  describe "#unbindKeys", ->
    beforeEach ->
      @keyboardHandler.bindKeys()
      
      @keyboardHandler.unbindKeys()

    it "unbinds the events", ->
      for event, callback of @handlers
        expect($(document)).not.toHandleWith(event, callback)
    
  describe "after start", ->
    beforeEach ->
      @keyboardHandler.start()
      
    afterEach ->
      @keyboardHandler.stop()
      
    describe "#onKeyDown", ->
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
        
      describe "up arrow", ->
        beforeEach ->
          @onUpArrowStub = sinon.stub(@keyboardHandler, "onUpArrow", ->)
          
          @event.which = 38
          $(document).trigger(@event)
          
        afterEach ->
          @onUpArrowStub.restore()
          
        it "calls onUpArrow", ->
          expect(@onUpArrowStub).toHaveBeenCalledWith(@event)

      describe "down arrow", ->
        beforeEach ->
          @onDownArrowStub = sinon.stub(@keyboardHandler, "onDownArrow", ->)
          
          @event.which = 40
          $(document).trigger(@event)

        afterEach ->
          @onDownArrowStub.restore()

        it "calls onDownArrow", ->
          expect(@onDownArrowStub).toHaveBeenCalledWith(@event)

    describe "#onUpArrow", ->
      # TODO figure out how to test prevenDefault - spyOnEvent isn't working
      
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
        @event.which = 38

        @moveSelectionUpStub = sinon.stub(@keyboardHandler.app.views.mainView.emailThreadsListView, "moveSelectionUp")

        $(document).trigger(@event)

      it "moves the selection up on the email threads list view", ->
        expect(@moveSelectionUpStub).toHaveBeenCalled()

    describe "#onDownArrow", ->
      # TODO figure out how to test prevenDefault - spyOnEvent isn't working
      
      beforeEach ->
        @event = jQuery.Event("keydown")
        @event.data = @keyboardHandler
        @event.which = 40

        @moveSelectionDownStub = sinon.stub(@keyboardHandler.app.views.mainView.emailThreadsListView, "moveSelectionDown")

        $(document).trigger(@event)

      it "moves the selection down on the email threads list view", ->
        expect(@moveSelectionDownStub).toHaveBeenCalled()
