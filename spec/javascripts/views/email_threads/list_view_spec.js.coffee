describe "ListView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()

    @listViewDiv = $("<div />", {id: "email_table_body"}).appendTo('body')
    @listView = new TuringEmailApp.Views.EmailThreads.ListView(
      app: TuringEmailApp
      el: @listViewDiv
      collection: @emailThreads
    )

    emailThreadsFixtures = fixture.load("email_threads.fixture.json");
    @validEmailThreadsFixture = emailThreadsFixtures[0]["valid"]
    emailThreadFixtures = fixture.load("email_thread.fixture.json")
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]

    @emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: @validEmailThreadFixture["uid"])
    
    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @emailThreads.url, JSON.stringify(@validEmailThreadsFixture)

    @url = "/api/v1/email_threads/show/" + @validEmailThreadFixture["uid"]
    @server.respondWith "GET", @url, JSON.stringify(@validEmailThreadFixture)

  afterEach ->
    @server.restore()

  describe "after fetch", ->

    beforeEach ->
      @emailThreads.fetch(reset: true)
      @server.respond()

    afterEach ->
      @listView.removeAll()

    describe "#initialize", ->

      beforeEach ->
        @emailThread.fetch()
        @server.respond()

        # TODO write tests for reset, destroy and change:currentEmailThread

      it "adds a listener for add that calls @addOne", ->
        @listView.collection.add @emailThread
        expect(@listView.listItemViews[@emailThread.get("uid")]).toBeTruthy()

      it "adds a listener for remove that calls @removeOne", ->
        @listView.collection.add @emailThread
        expect(@listView.listItemViews[@emailThread.get("uid")]).toBeTruthy()
        @listView.collection.remove @emailThread
        expect(@listView.listItemViews[@emailThread.get("uid")]).toBeFalsy()

    describe "#render", ->
      it "renders the email threads", ->
        expect(@listViewDiv.find("tr").length).toEqual(@emailThreads.models.length)

    describe "#resetView", ->
      it "calls render", ->
        @spy = sinon.spy(@listView, "render")
        @listView.resetView()
        expect(@spy).toHaveBeenCalled()

      it "calls removeAll if options.previousModels is passed in", ->
        @emailThread.fetch()
        @server.respond()

        @spy = sinon.spy(@listView, "removeAll")

        @listView.collection.add @emailThread
        options = {}
        options.previousModels = @listView.collection.models

        @listView.resetView @listView.collection.models, options.previousModels

        expect(@spy).toHaveBeenCalled()

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

    describe "#setupKeyboardShortcuts", ->
      it "adds the email_thread_highlight class", ->
        element = @listView.$el.find("tr:nth-child(1)")
        element.removeClass("email_thread_highlight")
        expect(element).not.toHaveClass("email_thread_highlight")
        @listView.setupKeyboardShortcuts()
        expect(element).toHaveClass("email_thread_highlight")

    describe "#moveTuringEmailReportToTop", ->

      describe "if there is a report email", ->

        beforeEach ->
          @turingEmailThread = _.values(@listView.listItemViews)[0].model

          @listView.collection.remove @turingEmailThread
          @turingEmailThread.get("emails")[0].from_name = "Turing Email"
          @listView.collection.add @turingEmailThread

        it "should move the email to the top", ->
          expect($("#email_table_body").children()[0]).not.toContainText("Turing Email")

          @listView.moveTuringEmailReportToTop()

          expect($("#email_table_body").children()[0]).toContainText("Turing Email")

      describe "if there is not a report email", ->

        it "should leave the emails in the same order", ->
          emailTableBodyBefore = $("#email_table_body")
          @listView.moveTuringEmailReportToTop()
          emailTableBodyAfter = $("#email_table_body")

          expect(emailTableBodyBefore).toEqual emailTableBodyAfter

    describe "#getSelectedEmailThreads", ->

      beforeEach ->
        _.values(@listView.listItemViews)[0].select()

      it "should return an array with the selected email threads", ->
        selectedEmailThreads = @listView.getSelectedEmailThreads()

        for listItemView in _.values(@listView.listItemViews)
          if listItemView.isChecked()
            expect(selectedEmailThreads).toContain listItemView.model

    describe "#selectAll", ->
      it "calls select on each listItemView", ->
        spies = []
        for listItemView in _.values(@listView.listItemViews)
          @spy = sinon.spy(listItemView, "select")
          spies.push(@spy)
        @listView.selectAll()
        for spy in spies
          expect(spy).toHaveBeenCalled()

    describe "#selectAllRead", ->
      it "calls select on each read listItemView and deselect on each unread listItemView", ->
        select_spies = []
        deselect_spies = []

        for listItemView in _.values(@listView.listItemViews)
          if listItemView.model.get("emails")[0].seen
            @spy = sinon.spy(listItemView, "select")
            select_spies.push(@spy)
          else
            @spy = sinon.spy(listItemView, "deselect")
            deselect_spies.push(@spy)

        @listView.selectAllRead()

        expect(spy).toHaveBeenCalled() for spy in select_spies
        expect(spy).toHaveBeenCalled() for spy in deselect_spies

    describe "#selectAllUnread", ->
      it "calls select on each unread listItemView and deselect on each read listItemView", ->
        select_spies = []
        deselect_spies = []

        for listItemView in _.values(@listView.listItemViews)
          if listItemView.model.get("emails")[0].seen
            @spy = sinon.spy(listItemView, "deselect")
            deselect_spies.push(@spy)
          else
            @spy = sinon.spy(listItemView, "select")
            select_spies.push(@spy)

        @listView.selectAllUnread()

        expect(spy).toHaveBeenCalled() for spy in select_spies
        expect(spy).toHaveBeenCalled() for spy in deselect_spies

    describe "#deselectAll", ->
      it "calls deselect on each listItemView", ->
        spies = []
        for listItemView in _.values(@listView.listItemViews)
          @spy = sinon.spy(listItemView, "deselect")
          spies.push(@spy)
        @listView.deselectAll()
        for spy in spies
          expect(spy).toHaveBeenCalled()

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

    describe "#markSelectedRead", ->

      beforeEach ->
        _.values(@listView.listItemViews)[0].select()

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

        @listView.markSelectedRead()

        for spy in @shouldBeCalledSpies
          expect(spy).toHaveBeenCalled()

        for spy in @shouldNotBeCalledSpies
          expect(spy).not.toHaveBeenCalled()

    describe "#markSelectedUnread", ->

      beforeEach ->
        _.values(@listView.listItemViews)[0].select()

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
        @listView.markSelectedUnread()

        for spy in @shouldBeCalledSpies
          expect(spy).toHaveBeenCalled()

        for spy in @shouldNotBeCalledSpies
          expect(spy).not.toHaveBeenCalled()

    describe "#currentEmailThreadChanged", ->

      beforeEach ->
        @emailThread = @listView.collection.models[0]

      it "calls deselectAll", ->
        @spy = sinon.spy(@listView, "deselectAll")
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        expect(@spy).toHaveBeenCalled()

      it "calls highlight and markRead on the new email thread", ->
        listItemView = @listView.listItemViews[@emailThread.get("uid")]
        highlightSpy = sinon.spy(listItemView, "highlight")
        markReadSpy = sinon.spy(listItemView, "markRead")
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        expect(highlightSpy).toHaveBeenCalled()
        expect(markReadSpy).toHaveBeenCalled()

      it "updates the currentEmailThread attribute", ->
        TuringEmailApp.currentEmailThread = @emailThread
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        expect(@listView.currentEmailThread).toEqual @emailThread

      it "calls unhighlight on the previous emailThread", ->
        #Set an email thread
        TuringEmailApp.currentEmailThread = @emailThread
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        
        #Update the email thread
        nextCurrentEmailThread = @listView.collection.models[1]

        listItemView = @listView.listItemViews[@emailThread.get("uid")]
        unhighlightSpy = sinon.spy(listItemView, "unhighlight")
        @listView.currentEmailThreadChanged(TuringEmailApp, nextCurrentEmailThread)
        expect(unhighlightSpy).toHaveBeenCalled()

    describe "#listItemClicked", ->

      it "triggers the change:selection event", ->
        spy = sinon.backbone.spy(@listView, "change:selection")
        
        listItemView = _.values(@listView.listItemViews)[0]
        @listView.listItemClicked(listItemView)
        
        expect(spy).toHaveBeenCalledWith(@listView, listItemView.model)
