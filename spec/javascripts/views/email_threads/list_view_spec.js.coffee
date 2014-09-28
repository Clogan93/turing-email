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
