describe "EmailFolder model", ->

  beforeEach ->
    @email_folder = new TuringEmailApp.Models.EmailFolder()
    collection = url: "/api/v1/email_folders"
    @email_folder.collection = collection

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailFolder).toBeDefined()

  it "should have the right url", ->
    expect(@email_folder.url()).toEqual '/api/v1/email_folders'

  describe "when instantiated using fetch with data from the server", ->

    beforeEach ->
      @fixtures = fixture.load("email_folder.fixture.json", true);

      @validEmailFolder = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_folders", JSON.stringify(@validEmailFolder)
      return

    afterEach ->
      @server.restore()

    it "should make the correct request", ->
      @email_folder.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_folders"
      return

    it "should parse the attributes from the response", ->
      @email_folder.fetch()
      @server.respond()

      expect(@email_folder.get("label_id")).toEqual @validEmailFolder.label_id
      expect(@email_folder.get("label_list_visibility")).toEqual @validEmailFolder.label_list_visibility
      expect(@email_folder.get("label_type")).toEqual @validEmailFolder.label_type
      expect(@email_folder.get("message_list_visibility")).toEqual @validEmailFolder.message_list_visibility
      expect(@email_folder.get("name")).toEqual @validEmailFolder.name
      expect(@email_folder.get("num_threads")).toEqual @validEmailFolder.num_threads
      expect(@email_folder.get("num_unread_threads")).toEqual @validEmailFolder.num_unread_threads
      return

    it "should have the attributes", ->
      @email_folder.fetch()
      @server.respond()
      
      expect(@email_folder.get("label_id")).toBeDefined()
      expect(@email_folder.get("label_list_visibility")).toBeDefined()
      expect(@email_folder.get("label_type")).toBeDefined()
      expect(@email_folder.get("message_list_visibility")).toBeDefined()
      expect(@email_folder.get("name")).toBeDefined()
      expect(@email_folder.get("num_threads")).toBeDefined()
      expect(@email_folder.get("num_unread_threads")).toBeDefined()
