describe "ListView", ->

  beforeEach ->
    TuringEmailApp.user = new TuringEmailApp.Models.User()
    @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(
      folderID: "INBOX"
    )
    @listView = new TuringEmailApp.Views.EmailThreads.ListView(
      collection: @emailThreads
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailThreads.ListView).toBeDefined()
 
   it "should have the right collection", ->
    expect(@listView.collection).toEqual @emailThreads

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("email_threads.fixture.json", "user.fixture.json", true)

      @validUser = @fixtures[1]["valid"]
      @validEmailThreadsFixture = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()

      @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUser)
      TuringEmailApp.user.fetch()
      @server.respond()

      @server.respondWith "GET", "/api/v1/email_threads/in_folder?folder_id=INBOX", JSON.stringify(@validEmailThreadsFixture)
      @emailThreads.fetch()
      @server.respond()

      return

    afterEach ->
      @server.restore()

    it "should have the root element be a div", ->
      expect(@listView.el.nodeName).toEqual "DIV"

    it "should render the attributes of all the email threads", ->
      #Set up lists
      fromNames = []
      subjects = []
      snippets = []
      links = []

      #Collect Attributes from the rendered DOM.
      @listView.$el.find('td.mail-contact a').each ->
        fromNames.push $(this).text().trim()
      @listView.$el.find('td.mail-subject a').each ->
        subjects.push $(this).text().trim()
      @listView.$el.find('a').each ->
        links.push $(this).attr("href")
      links = _.uniq(links, false)

      #Run expectations
      for emailThread, index in @emailThreads.models
        email = emailThread.get("emails")[0]
        
        expect(fromNames[index]).toEqual email.from_name
        expect(subjects[index]).toEqual email.subject
        expect(links[index]).toEqual "#email_thread/" + emailThread.get("uid")
