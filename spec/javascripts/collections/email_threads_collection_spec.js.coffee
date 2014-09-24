describe "EmailThreads collection", ->
  beforeEach ->
    @url = "/api/v1/email_threads/in_folder?folder_id=INBOX"
    @emailThreadsCollection = new TuringEmailApp.Collections.EmailThreadsCollection(folder_id: "INBOX")

    emailThreads = fixture.load("email_threads.fixture.json");
    @validEmailThreads = emailThreads[0]["valid"]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @url, JSON.stringify(@validEmailThreads)

    @emailThreadsCollection.fetch()
    @server.respond()
    
  afterEach ->
    @server.restore()
    
  it "should use the EmailThread model", ->
    expect(@emailThreadsCollection.model).toEqual TuringEmailApp.Models.EmailThread

  it "should have the right url", ->
    expect(@emailThreadsCollection.url).toEqual @url

  describe "#fetch", ->
    it "loads the email threads", ->
      expect(@emailThreadsCollection.length).toEqual @validEmailThreads.length
      expect(@emailThreadsCollection.toJSON()).toEqual @validEmailThreads

      for emailThread in @emailThreadsCollection.models
        validateEmailThreadAttributes(emailThread.toJSON())
        
        for email in emailThread.get("emails")
          validateEmailAttributes(email)

  describe "#getEmailThread", ->
    it "returns the email thread with the specified uid", ->
      for emailThread in @emailThreadsCollection.models
        retrievedEmailThread = @emailThreadsCollection.getEmailThread emailThread.get("uid")
        expect(emailThread).toEqual retrievedEmailThread
