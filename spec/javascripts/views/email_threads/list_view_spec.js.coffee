describe "ListView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined, app: TuringEmailApp)

    @listView = new TuringEmailApp.Views.EmailThreads.ListView(
      collection: @emailThreads
    )
    $("body").append(@listView.$el)

    emailThreadAttributes = FactoryGirl.create("EmailThread")
    @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes,
      app: TuringEmailApp
      emailThreadUID: emailThreadAttributes.uid
    )

  afterEach ->
    @listView.$el.remove()
    
    specStopTuringEmailApp()

  describe "after fetch", ->

    beforeEach ->
      @emailThreads.reset(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))

    afterEach ->
      @listView.removeAll()

    describe "#initialize", ->

      it "adds a listener for add that calls @addOne", ->
        @listView.collection.add @emailThread
        expect(@listView.listItemViews[@emailThread.get("uid")]).toBeTruthy()

      it "adds a listener for remove that calls @removeOne", ->
        @listView.collection.add @emailThread
        expect(@listView.listItemViews[@emailThread.get("uid")]).toBeTruthy()
        @listView.collection.remove @emailThread
        expect(@listView.listItemViews[@emailThread.get("uid")]).toBeFalsy()

      # TODO write tests for reset, destroy

    describe "#render", ->
      it "renders the email threads", ->
        expect(@listView.$el.find("tr").length).toEqual(@emailThreads.models.length)

    describe "#resetView", ->
      it "render", ->
        @spy = sinon.spy(@listView, "render")
        @listView.resetView()
        expect(@spy).toHaveBeenCalled()
        @spy.restore()

      it "calls removeAll if options.previousModels is passed in", ->
        @spy = sinon.spy(@listView, "removeAll")

        @listView.collection.add @emailThread
        options = {}
        options.previousModels = @listView.collection.models

        @listView.resetView @listView.collection.models, options.previousModels

        expect(@spy).toHaveBeenCalled()
        @spy.restore()

    describe "Collection Functions", ->
      describe "#addOne", ->
        it "adds an email thread to the view", ->
          currentlyDisplayedListItemViews = _.values(@listView.listItemViews)
          emailThreadView = currentlyDisplayedListItemViews[0]
          @listView.removeOne(emailThreadView.model)
  
          expect(emailThreadView in _.values(@listView.listItemViews)).toBeFalsy()
          expect(emailThreadView.el).not.toBeInDOM()
          @listView.addOne(emailThreadView.model)
  
          emailThreadView = @listView.listItemViews[emailThreadView.model.get("uid")]
          expect(emailThreadView in _.values(@listView.listItemViews)).toBeTruthy()
          expect(emailThreadView.el).toBeInDOM()
  
        it "adds an email thread to the view even when listItemViews is null", ->
          currentlyDisplayedListItemViews = _.values(@listView.listItemViews)
          emailThreadView = currentlyDisplayedListItemViews[0]
          @listView.listItemViews = null
          @listView.removeAll()
          @listView.addOne(emailThreadView.model)
          emailThreadView = @listView.listItemViews[emailThreadView.model.get("uid")]
          expect(emailThreadView in _.values(@listView.listItemViews)).toBeTruthy()
          expect(emailThreadView.el).toBeInDOM()
  
      describe "#removeOne", ->
        it "removes an email thread to the view", ->
          currentlyDisplayedListItemViews = _.values(@listView.listItemViews)
          emailThreadView = currentlyDisplayedListItemViews[0]
  
          @listView.removeOne(emailThreadView.model)
          expect(emailThreadView.el).not.toBeInDOM()
          expect(emailThreadView in _.values(@listView.listItemViews)).toBeFalsy()

      describe "#addAll", ->
        it "adds all the list item views to the list view", ->
          @listView.removeAll()
  
          expect(_.values(@listView.listItemViews).length is 0).toBeTruthy()
  
          @spy = sinon.spy(@listView, "addOne")
          @listView.addAll()
          
          expect(_.values(@listView.listItemViews).length is @emailThreads.length).toBeTruthy()
  
          for emailThread in @listView.collection.models
            expect(@spy).toHaveBeenCalledWith(emailThread)

          @spy.restore()
  
      describe "#removeAll", ->
        it "removes all the list item views from the list view", ->
          initiallyDisplayedListItemViews = _.values(@listView.listItemViews)
  
          for listItemView in initiallyDisplayedListItemViews
            expect(listItemView.el).toBeInDOM()
  
          expect(initiallyDisplayedListItemViews.length is @emailThreads.length).toBeTruthy()
          
          @listView.removeAll()
  
          expect(_.values(@listView.listItemViews).length is 0).toBeTruthy()
  
          for listItemView in initiallyDisplayedListItemViews
            expect(listItemView.el).not.toBeInDOM()

    describe "Getters", ->
      describe "#selectedItem", ->
        describe "no item selected", ->
          it "returns null", ->
            expect(@listView.selectedItem()).toEqual(null)

        describe "item selected", ->
          beforeEach ->
            @listItemView = _.values(@listView.listItemViews)[0]
            @listView.select(@listItemView.model)

          it "returns the list item", ->
            expect(@listView.selectedItem()).toEqual(@listItemView.model)
      
      describe "#selectedIndex", ->

        it "correctly gets the selected index of each list item", ->
          for listItemView, index in _.values(@listView.listItemViews)
            @listView.select(listItemView.model)
            expect(@listView.selectedIndex()).toEqual index

      describe "#getCheckedListItemViews", ->
        beforeEach ->
          _.values(@listView.listItemViews)[0].check()
  
        it "returns the checked list items", ->
          checkedListItemViews = @listView.getCheckedListItemViews()
  
          numListItemsChecked = 0
          for listItemView in _.values(@listView.listItemViews)
            if listItemView.isChecked()
              numListItemsChecked += 1
              expect(checkedListItemViews).toContain listItemView
              
          expect(checkedListItemViews.length).toEqual(numListItemsChecked)

    describe "Setters", ->
      describe "#selectedIndexIs", ->

        it "correctly sets the selected index of each list item", ->
          for listItemView, index in _.values(@listView.listItemViews)
            @listView.selectedIndexIs index
            expect(@listView.selectedIndex()).toEqual index

    describe "Actions", ->
      describe "#checkAll", ->
        it "checks all list items", ->
          spies = []
          for listItemView in _.values(@listView.listItemViews)
            @spy = sinon.spy(listItemView, "check")
            spies.push(@spy)
          
          @listView.checkAll()
          
          for spy in spies
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
      describe "#checkAllRead", ->
        it "checks read list items and unchecks unread list items", ->
          select_spies = []
          deselect_spies = []
  
          for listItemView in _.values(@listView.listItemViews)
            if listItemView.model.get("emails")[0].seen
              @spy = sinon.spy(listItemView, "check")
              select_spies.push(@spy)
            else
              @spy = sinon.spy(listItemView, "uncheck")
              deselect_spies.push(@spy)
  
          @listView.checkAllRead()
  
          for spy in select_spies
            expect(spy).toHaveBeenCalled()
            spy.restore()
          for spy in deselect_spies
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
      describe "#checkAllUnread", ->
        it "checks unread list items and checks unread list items", ->
          select_spies = []
          deselect_spies = []
  
          for listItemView in _.values(@listView.listItemViews)
            if listItemView.model.get("emails")[0].seen
              @spy = sinon.spy(listItemView, "uncheck")
              deselect_spies.push(@spy)
            else
              @spy = sinon.spy(listItemView, "check")
              select_spies.push(@spy)
  
          @listView.checkAllUnread()
  
          for spy in select_spies
            expect(spy).toHaveBeenCalled()
            spy.restore()
          for spy in deselect_spies
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
      describe "#uncheckAll", ->
        it "unchecks all list items", ->
          spies = []
          for listItemView in _.values(@listView.listItemViews)
            @spy = sinon.spy(listItemView, "uncheck")
            spies.push(@spy)
            
          @listView.uncheckAll()
          
          for spy in spies
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
      describe "#markEmailThreadRead", ->
  
        beforeEach ->
          @firstEmailThread = _.values(@listView.listItemViews)[0].model
  
        it "should mark the passed in email thread as read", ->
          @listView.markEmailThreadRead @firstEmailThread
          expect(@listView.listItemViews[@firstEmailThread.get("uid")].$el).toHaveClass("read")
  
      describe "#markEmailThreadUnread", ->
  
        beforeEach ->
          @firstEmailThread = _.values(@listView.listItemViews)[0].model
  
        it "should mark the passed in email thread as unread", ->
          @listView.markEmailThreadUnread @firstEmailThread
          expect(@listView.listItemViews[@firstEmailThread.get("uid")].$el).toHaveClass("unread")
  
      describe "#markCheckedRead", ->
  
        beforeEach ->
          _.values(@listView.listItemViews)[0].check()
  
          @shouldBeCalledSpies = []
          @shouldNotBeCalledSpies = []
  
          for listItemView in _.values(@listView.listItemViews)
            spy = sinon.spy(listItemView, "markRead")
            if listItemView.isChecked()
              @shouldBeCalledSpies.push(spy)
            else
              @shouldNotBeCalledSpies.push(spy)
  
        it "should have the correct test data", ->
          expect(@shouldBeCalledSpies.length > 0).toBeTruthy()
          expect(@shouldNotBeCalledSpies.length > 0).toBeTruthy()
  
        it "should call markRead() on all selected listItemViews", ->
  
          @listView.markCheckedRead()
  
          for spy in @shouldBeCalledSpies
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
          for spy in @shouldNotBeCalledSpies
            expect(spy).not.toHaveBeenCalled()
            spy.restore()
  
      describe "#markCheckedUnread", ->
        beforeEach ->
          _.values(@listView.listItemViews)[0].check()
  
          @shouldBeCalledSpies = []
          @shouldNotBeCalledSpies = []
  
          for listItemView in _.values(@listView.listItemViews)
            spy = sinon.spy(listItemView, "markUnread")
            if listItemView.isChecked()
              @shouldBeCalledSpies.push(spy)
            else
              @shouldNotBeCalledSpies.push(spy)
  
        it "should have the correct test data", ->
          expect(@shouldBeCalledSpies.length > 0).toBeTruthy()
          expect(@shouldNotBeCalledSpies.length > 0).toBeTruthy()
  
        it "should call markUnread() on all selected listItemViews", ->
          @listView.markCheckedUnread()
  
          for spy in @shouldBeCalledSpies
            expect(spy).toHaveBeenCalled()
            spy.restore()
  
          for spy in @shouldNotBeCalledSpies
            expect(spy).not.toHaveBeenCalled()
            spy.restore()
  
      describe "#moveSelectionUp", ->
        beforeEach ->
          @numListItemViews = _.values(@listView.listItemViews).length
          
          @firstListItemView = _.values(@listView.listItemViews)[0]
          @lastListItemView = _.values(@listView.listItemViews)[@numListItemViews - 1]
          @secLastListItemView = _.values(@listView.listItemViews)[@numListItemViews - 2]
          
          @selectSpy = sinon.spy(@listView, "select")
          @scrollListItemIntoViewSpy = sinon.spy(@listView, "scrollListItemIntoView")
          
        afterEach ->
          @selectSpy.restore()
          @scrollListItemIntoViewSpy.restore()
  
        describe "last item selected", ->
          beforeEach ->
            @listView.select(@lastListItemView.model)
  
            @listItemViewSelected = @listView.moveSelectionUp()
          
          it "selects the second to last list item view", ->
            expect(@selectSpy).toHaveBeenCalledWith(@secLastListItemView.model)
              
          it "scrolls the second to last list item view into view", ->
            expect(@scrollListItemIntoViewSpy).toHaveBeenCalledWith(@secLastListItemView, "top")
            
          it "returns the selected list item view", ->
            expect(@listItemViewSelected).toEqual(@secLastListItemView)

        describe "first item selected", ->
          beforeEach ->
            @listView.select(@firstListItemView.model)
            
          it "does not move the selection", ->
            expect(@listView.moveSelectionUp()).toBeFalsy()

        describe "no item selected", ->
          it "does not move the selection", ->
            expect(@listView.moveSelectionUp()).toBeFalsy()

      describe "#moveSelectionDown", ->
        beforeEach ->
          @numListItemViews = _.values(@listView.listItemViews).length

          @firstListItemView = _.values(@listView.listItemViews)[0]
          @secListItemView = _.values(@listView.listItemViews)[1]
          @lastListItemView = _.values(@listView.listItemViews)[@numListItemViews - 1]

          @selectSpy = sinon.spy(@listView, "select")
          @scrollListItemIntoViewSpy = sinon.spy(@listView, "scrollListItemIntoView")

        afterEach ->
          @selectSpy.restore()
          @scrollListItemIntoViewSpy.restore()

        describe "first item selected", ->
          beforeEach ->
            @listView.select(@firstListItemView.model)

            @listItemViewSelected = @listView.moveSelectionDown()

          it "selects the second list item view", ->
            expect(@selectSpy).toHaveBeenCalledWith(@secListItemView.model)

          it "scrolls the second list item view into view", ->
            expect(@scrollListItemIntoViewSpy).toHaveBeenCalledWith(@secListItemView, "bottom")

          it "returns the selected list item view", ->
            expect(@listItemViewSelected).toEqual(@secListItemView)

        describe "last item selected", ->
          beforeEach ->
            @listView.select(@lastListItemView.model)

          it "does not move the selection", ->
            expect(@listView.moveSelectionDown()).toBeFalsy()

        describe "no item selected", ->
          it "does not move the selection", ->
            expect(@listView.moveSelectionDown()).toBeFalsy()
      
    describe "#scrollListItemIntoView", ->
      beforeEach ->
        @listItemView = _.values(@listView.listItemViews)[0]
        @el = @listItemView.$el
        
        @parent = @el.parent().parent()
        @top = @el.position().top
        @bottom = @top + @el.outerHeight(true)
        
      describe "listItemView is on screen", ->
        beforeEach ->
          @parent.scrollTop(@top)
          @scrollTopSpy = sinon.spy(@parent, "scrollTop")

        afterEach ->
          @parent.scrollTop(0)
          @scrollTopSpy.restore()

        describe "position=bottom", ->
          beforeEach ->
            @listView.scrollListItemIntoView(@listItemView, "bottom")
            
          it "not to have scrolled", ->
            expect(@scrollTopSpy).not.toHaveBeenCalled()

        describe "position=top", ->
          beforeEach ->
            @listView.scrollListItemIntoView(@listItemView, "top")

          it "not to have scrolled", ->
            expect(@scrollTopSpy).not.toHaveBeenCalled()

      describe "listItemView is off screen", ->
        beforeEach ->
          @el.css("top": @parent.height() + "px", "position": "absolute")
          @top = @el.position().top
          @bottom = @top + @el.outerHeight(true)
        
          @scrollTopSpy = sinon.spy($.prototype, "scrollTop")

        afterEach ->
          @scrollTopSpy.restore()

        describe "position=bottom", ->
          beforeEach ->
            @listView.scrollListItemIntoView(@listItemView, "bottom")

          it "to have scrolled the list item into view", ->
            expect(@scrollTopSpy).toHaveBeenCalledWith(@bottom - @parent.height())

        describe "position=top", ->
          beforeEach ->
            @listView.scrollListItemIntoView(@listItemView, "top")

          it "to have scrolled the list item into view", ->
            expect(@scrollTopSpy).toHaveBeenCalled(@top)
            
    describe "ListItemView Events", ->
      describe "#hookListItemViewEvents", ->
        beforeEach ->
          @listenToSpy = sinon.spy(@listView, "listenTo")
          
          @listItemView = _.values(@listView.listItemViews)[0]
          @listView.hookListItemViewEvents(@listItemView)
        
        afterEach ->
          @listenToSpy.restore()
          
        describe "click", ->
          beforeEach ->
            @selectStub = sinon.stub(@listView, "select", ->)
            @listItemView.trigger("click", @listItemView)
            
          afterEach ->
            @selectStub.restore()
            
          it "hooks the click event", ->
            expect(@listenToSpy).toHaveBeenCalledWith(@listItemView, "click")
            
          it "on click it selects the model", ->
            expect(@selectStub).toHaveBeenCalledWith(@listItemView.model)
  
        events =
          "selected": "listItemSelected"
          "deselected": "listItemDeselected"
          "checked": "listItemChecked"
          "unchecked": "listItemUnchecked"
        
        for listItemEvent, listViewEvent of events
          describe listItemEvent, ->
            beforeEach ->
              @listViewEventSpy = sinon.backbone.spy(@listView, listViewEvent)
              @listItemView.trigger(listItemEvent, @listItemView)
      
            afterEach ->
              @listViewEventSpy.restore()
      
            it "hooks the " + listItemEvent + " event", ->
              expect(@listenToSpy).toHaveBeenCalledWith(@listItemView, listItemEvent)
      
            it "on selected it triggers " + listViewEvent, ->
              expect(@listViewEventSpy).toHaveBeenCalledWith(@listView, @listItemView)
