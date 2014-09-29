describe "ListView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined, folderID: "INBOX")

    @listViewDiv = $("<div />", {id: "email_table_body"}).appendTo('body')
    @listView = new TuringEmailApp.Views.EmailThreads.ListView(
      el: @listViewDiv
      collection: @emailThreads
    )

    emailThreadsFixtures = fixture.load("email_threads.fixture.json");
    @validEmailThreadsFixture = emailThreadsFixtures[0]["valid"]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @emailThreads.url, JSON.stringify(@validEmailThreadsFixture)

  afterEach ->
    @server.restore()

  describe "after fetch", ->

    beforeEach ->
      @emailThreads.fetch(reset: true)
      @server.respond()

    afterEach ->
      @listView.removeAll()

    describe "#render", ->
      it "renders the email threads", ->
        expect(@listViewDiv.find("tr").length).toEqual(@emailThreads.models.length)

    describe "#reset", ->
      it "calls render", ->
        @spy = sinon.spy(@listView, "render")
        @listView.resetView()
        expect(@spy).toHaveBeenCalled()

    describe "#setupKeyboardShortcuts", ->
      it "adds the email_thread_highlight class", ->
        element = @listView.$el.find("tr:nth-child(1)")
        element.removeClass("email_thread_highlight")
        expect(element).not.toHaveClass("email_thread_highlight")
        @listView.setupKeyboardShortcuts()
        expect(element).toHaveClass("email_thread_highlight")

    describe "#removeOne", ->
      it "removes an email thread to the view", ->
        currentlyDisplayedListItemViews = _.values(@listView.listItemViews)
        emailThreadView = currentlyDisplayedListItemViews[0]

        @listView.removeOne(emailThreadView.model)
        expect(emailThreadView.el).not.toBeInDOM()
        expect(emailThreadView in _.values(@listView.listItemViews)).toBeFalsy()

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

    describe "#addAll", ->
      it "adds all the list item views to the list view", ->
        @listView.removeAll()

        expect(_.values(@listView.listItemViews).length is 0).toBeTruthy()

        @spy = sinon.spy(@listView, "addOne")
        @listView.addAll()
        
        expect(_.values(@listView.listItemViews).length is @emailThreads.length).toBeTruthy()

        for emailThread in @listView.collection.models
          expect(@spy).toHaveBeenCalledWith(emailThread)

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

    describe "#currentEmailThreadChanged", ->

      beforeEach ->
        @emailThread = @listView.collection.models[0]

      it "calls deselectAll", ->
        @spy = sinon.spy(@listView, "deselectAll")
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        expect(@spy).toHaveBeenCalled()

      it "calls highlight on the new email thread", ->
        listItemView = @listView.listItemViews[@emailThread.get("uid")]
        @spy = sinon.spy(listItemView, "highlight")
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        expect(@spy).toHaveBeenCalled()

      it "updates the currentlySelectedEmailThread attribute", ->
        TuringEmailApp.currentEmailThread = @emailThread
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        expect(@listView.currentlySelectedEmailThread).toEqual @emailThread

      it "calls unhighlight and markRead on the previous emailThread", ->
        #Set an email thread
        TuringEmailApp.currentEmailThread = @emailThread
        @listView.currentEmailThreadChanged(TuringEmailApp, @emailThread)
        
        #Update the email thread
        nextCurrentEmailThread = @listView.collection.models[1]

        listItemView = @listView.listItemViews[@emailThread.get("uid")]
        unhighlightSpy = sinon.spy(listItemView, "unhighlight")
        markReadSpy = sinon.spy(listItemView, "markRead")
        @listView.currentEmailThreadChanged(TuringEmailApp, nextCurrentEmailThread)
        expect(unhighlightSpy).toHaveBeenCalled()
        expect(markReadSpy).toHaveBeenCalled()

    describe "#toolbarViewChanged", ->

      beforeEach ->
        @newToolbarView = new TuringEmailApp.Views.ToolbarView(
          el: $("#email-folder-mail-header")
          collection: TuringEmailApp.collections.emailFolders
        )

      it "updates the currentToolbarView attribute", ->
        currentToolbarView = @listView.currentToolbarView

        @listView.toolbarViewChanged(TuringEmailApp, @newToolbarView)

        expect(@listView.currentToolbarView).not.toEqual currentToolbarView
        expect(@listView.currentToolbarView).toEqual @newToolbarView

      it "starts listening to the @currentToolbarView", ->
        listenToSpy = sinon.spy(@listView, "listenTo")

        @listView.toolbarViewChanged(TuringEmailApp, @newToolbarView)

        expect(listenToSpy).toHaveBeenCalled()

        expect(listenToSpy).toHaveBeenCalledWith(@listView.currentToolbarView, "selectAll", @listView.selectAll)
        expect(listenToSpy).toHaveBeenCalledWith(@listView.currentToolbarView, "selectAllRead", @listView.selectAllRead)
        expect(listenToSpy).toHaveBeenCalledWith(@listView.currentToolbarView, "selectAllUnread", @listView.selectAllUnread)
        expect(listenToSpy).toHaveBeenCalledWith(@listView.currentToolbarView, "deselectAll", @listView.deselectAll)

    describe "#listItemClicked", ->

      it "marks non-draft emails as read when the email is not a draft", ->
        listItemView = _.values(@listView.listItemViews)[0]

        listItemView.model.get("emails")[0].draft_id = null

        spy = sinon.spy(listItemView, "markRead")
        @listView.listItemClicked listItemView

        expect(spy).toHaveBeenCalled()

        # TODO .

    #describe "#moveTuringEmailReportToTop", ->
