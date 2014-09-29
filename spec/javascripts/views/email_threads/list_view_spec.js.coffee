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

  describe "#render", ->
    beforeEach ->
      @emailThreads.fetch(reset: true)
      @server.respond()

    it "renders the email threads", ->
      expect(@listViewDiv.find("tr").length).toEqual(@emailThreads.models.length)

  describe "#reset", ->
    beforeEach ->
      @emailThreads.fetch(reset: true)
      @server.respond()

    it "calls render", ->
      @spy = sinon.spy(@listView, "render")
      @listView.reset()
      expect(@spy).toHaveBeenCalled()

  describe "#setupKeyboardShortcuts", ->
    beforeEach ->
      @emailThreads.fetch(reset: true)
      @server.respond()

    it "adds the email_thread_highlight class", ->
      element = @listView.$el.find("tr:nth-child(1)")
      element.removeClass("email_thread_highlight")
      expect(element).not.toHaveClass("email_thread_highlight")
      @listView.setupKeyboardShortcuts()
      expect(element).toHaveClass("email_thread_highlight")

  describe "#removeOne", ->
    beforeEach ->
      @emailThreads.fetch(reset: true)
      @server.respond()

    it "removes an email thread to the view", ->
      currentlyDisplayedListItemViews = _.values(@listView.listItemViews)
      emailThreadView = currentlyDisplayedListItemViews[0]

      @listView.removeOne(emailThreadView.model)
      expect(emailThreadView.el).not.toBeInDOM()
      expect(emailThreadView in _.values(@listView.listItemViews)).toBeFalsy()

  describe "#addOne", ->
    beforeEach ->
      @emailThreads.fetch(reset: true)
      @server.respond()

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
