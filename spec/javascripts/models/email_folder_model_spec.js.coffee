describe "EmailFolder model", ->

  beforeEach ->
    @emailFolder = new TuringEmailApp.Models.EmailFolder()
    collection = url: "/api/v1/email_folders"
    @emailFolder.collection = collection

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailFolder).toBeDefined()

  it "should have the right url", ->
    expect(@emailFolder.url()).toEqual '/api/v1/email_folders'

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
      @emailFolder.fetch()
      expect(@server.requests.length).toEqual 1
      expect(@server.requests[0].method).toEqual "GET"
      expect(@server.requests[0].url).toEqual "/api/v1/email_folders"
      return

    it "should parse the attributes from the response", ->
      @emailFolder.fetch()
      @server.respond()

      expect(@emailFolder.get("label_id")).toEqual @validEmailFolder.label_id
      expect(@emailFolder.get("label_list_visibility")).toEqual @validEmailFolder.label_list_visibility
      expect(@emailFolder.get("label_type")).toEqual @validEmailFolder.label_type
      expect(@emailFolder.get("message_list_visibility")).toEqual @validEmailFolder.message_list_visibility
      expect(@emailFolder.get("name")).toEqual @validEmailFolder.name
      expect(@emailFolder.get("num_threads")).toEqual @validEmailFolder.num_threads
      expect(@emailFolder.get("num_unread_threads")).toEqual @validEmailFolder.num_unread_threads
      return

    it "should have the attributes", ->
      @emailFolder.fetch()
      @server.respond()
      
      expect(@emailFolder.get("label_id")).toBeDefined()
      expect(@emailFolder.get("label_list_visibility")).toBeDefined()
      expect(@emailFolder.get("label_type")).toBeDefined()
      expect(@emailFolder.get("message_list_visibility")).toBeDefined()
      expect(@emailFolder.get("name")).toBeDefined()
      expect(@emailFolder.get("num_threads")).toBeDefined()
      expect(@emailFolder.get("num_unread_threads")).toBeDefined()
