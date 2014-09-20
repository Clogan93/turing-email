describe "ToolbarView", ->

  beforeEach ->
    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(
      folder_id: "INBOX"
    )
    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      collection: @emailFolders
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.ToolbarView).toBeDefined()

  it "loads the list item template", ->
    expect(@toolbarView.template).toEqual JST["backbone/templates/toolbar_view"]

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("email_folders.fixture.json", true)

      @validEmailFolders = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_folders", JSON.stringify(@validEmailFolders)

      @emailFolders.fetch()
      @server.respond()

      return

    afterEach ->
      @server.restore()

    it "has setupGoRight bind the click event to #paginate_right_link button", ->
      @toolbarView.render()
      element = @toolbarView.$el.find("#paginate_right_link")[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true
