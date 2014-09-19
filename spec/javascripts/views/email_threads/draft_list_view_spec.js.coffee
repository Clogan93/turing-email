describe "DraftListView", ->

  beforeEach ->
    TuringEmailApp.user = new TuringEmailApp.Models.User()
    @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folder_id: "INBOX"
    )
    @draftListView = new TuringEmailApp.Views.EmailThreads.DraftListView(
      collection: @emailThreads
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailThreads.DraftListView).toBeDefined()
 
   it "should have the right collection", ->
    expect(@draftListView.collection).toEqual @emailThreads

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("email_threads.fixture.json", "user.fixture.json", true)

      @validUser = @fixtures[1]["valid"]
      @validEmailThreads = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()

      @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUser)
      TuringEmailApp.user.fetch()
      @server.respond()

      @server.respondWith "GET", "/api/v1/email_threads/in_folder?folder_id=INBOX", JSON.stringify(@validEmailThreads)
      @emailThreads.fetch()
      @server.respond()

      return

    afterEach ->
      @server.restore()

    it "should have the root element be a div", ->
      expect(@draftListView.el.nodeName).toEqual "DIV"

    it "should render the attributes of all the email threads", ->
      #Set up lists
      fromNames = []
      subjects = []
      snippets = []
      links = []

      #Collect Attributes from the rendered DOM.
      @draftListView.$el.find('td.mail-ontact a').each ->
        fromNames.push $(this).text().trim()
      @draftListView.$el.find('td.mail-subject a').each ->
        subjects.push $(this).text().trim()
      @draftListView.$el.find('a').each ->
        links.push $(this).attr("href")
      links = _.uniq(links, false)

      #Run expectations
      for emailThread, index in @emailThreads.models
        console.log emailThread
        email = emailThread.get("emails")[0]
        
        expect(fromNames[index]).toEqual email.from_name
        expect(subjects[index]).toEqual email.subject
        expect(links[index]).toEqual "#email_draft#" + emailThread.get("uid")
