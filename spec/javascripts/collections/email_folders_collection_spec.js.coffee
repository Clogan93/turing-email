describe "EmailFolders collection", ->

  beforeEach ->
    @emailFoldersCollection = new TuringEmailApp.Collections.EmailFoldersCollection()

  it "should exist", ->
    expect(TuringEmailApp.Collections.EmailFoldersCollection).toBeDefined()

  it "should use the EmailFolder model", ->
      expect(@emailFoldersCollection.model).toEqual TuringEmailApp.Models.EmailFolder

  it "should have the right url", ->
    expect(@emailFoldersCollection.url).toEqual '/api/v1/email_folders'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("email_folders.fixture.json", true);

      @validEmailFolders = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_folders", JSON.stringify(@validEmailFolders)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @emailFoldersCollection.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_folders"
      return

    it "should parse the attributes from the response", ->
      @emailFoldersCollection.fetch()
      @server.respond()

      expect(@emailFoldersCollection.length).toEqual @validEmailFolders.length
      expect(@emailFoldersCollection.toJSON()).toEqual @validEmailFolders
      return

    it "should have the attributes", ->
      @emailFoldersCollection.fetch()
      @server.respond()

      for emailFolder in @emailFoldersCollection.models
        expect(emailFolder.get("label_id")).toBeDefined()
        expect(emailFolder.get("label_list_visibility")).toBeDefined()
        expect(emailFolder.get("label_type")).toBeDefined()
        expect(emailFolder.get("message_list_visibility")).toBeDefined()
        expect(emailFolder.get("name")).toBeDefined()
        expect(emailFolder.get("num_threads")).toBeDefined()
        expect(emailFolder.get("num_unread_threads")).toBeDefined()

    describe "when getEmailFolder is called", ->

      it "the correct email folder is returned", ->
        @emailFoldersCollection.fetch()
        @server.respond()

        for emailFolder in @emailFoldersCollection.models
          retrievedEmailFolder = @emailFoldersCollection.getEmailFolder emailFolder.get("label_id")
          expect(emailFolder).toEqual retrievedEmailFolder
