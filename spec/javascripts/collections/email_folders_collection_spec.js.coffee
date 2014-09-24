describe "EmailFolders collection", ->
  beforeEach ->
    @url = "/api/v1/email_folders"
    @emailFoldersCollection = new TuringEmailApp.Collections.EmailFoldersCollection()
    
    emailFolders = fixture.load("email_folders.fixture.json")
    @validEmailFolders = emailFolders[0]["valid"]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @url, JSON.stringify(@validEmailFolders)

    @emailFoldersCollection.fetch()
    @server.respond()

  afterEach ->
    @server.restore()
    
  it "should use the EmailFolder model", ->
    expect(@emailFoldersCollection.model).toEqual TuringEmailApp.Models.EmailFolder

  it "should have the right url", ->
    expect(@emailFoldersCollection.url).toEqual @url

  describe "#fetch", ->
    it "loads the email folders", ->
      expect(@emailFoldersCollection.length).toEqual @validEmailFolders.length
      expect(@emailFoldersCollection.toJSON()).toEqual @validEmailFolders

      for emailFolder in @emailFoldersCollection.models
        validateEmailFolderAttributes(emailFolder.toJSON())

  describe "#getEmailFolder", ->
    it "returns the email folder with the specified label_id", ->
      for emailFolder in @emailFoldersCollection.models
        retrievedEmailFolder = @emailFoldersCollection.getEmailFolder emailFolder.get("label_id")
        expect(emailFolder).toEqual retrievedEmailFolder
