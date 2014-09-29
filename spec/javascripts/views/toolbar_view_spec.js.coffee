describe "ToolbarView", ->

  beforeEach ->
    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(
      folderID: "INBOX"
    )
    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: TuringEmailApp
      collection: @emailFolders
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.ToolbarView).toBeDefined()

  it "loads the list item template", ->
    expect(@toolbarView.template).toEqual JST["backbone/templates/toolbar_view"]

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("email_folders.fixture.json", true)

      @validEmailFoldersFixture = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_folders", JSON.stringify(@validEmailFoldersFixture)

      @emailFolders.fetch()
      @server.respond()

      return

    afterEach ->
      @server.restore()

    it "has setupGoLeft bind the click event to the paginate left link", ->
      @toolbarView.render()
      element = @toolbarView.$el.find("#paginate_left_link")[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true

    it "has setupGoRight bind the click event to paginate right link", ->
      @toolbarView.render()
      element = @toolbarView.$el.find("#paginate_right_link")[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true

    it "has setupMoveToFolder bind the click event to move_to_folder_link links", ->
      @toolbarView.render()
      element = @toolbarView.$el.find(".move_to_folder_link")[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true

    it "has setupLabelAsLinks bind the click event to .label_as_link links", ->
      @toolbarView.render()
      element = @toolbarView.$el.find(".label_as_link")[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true

    it "has setupArchive bind the click event to the archive button", ->
      @toolbarView.render()
      element = @toolbarView.$el.find("i.fa-archive").parent()[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true

    it "has setupDelete bind the click event to the trash button", ->
      @toolbarView.render()
      element = @toolbarView.$el.find("i.fa-trash-o").parent()[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true

    it "has setupRead bind the click event to the slash button", ->
      @toolbarView.render()
      element = @toolbarView.$el.find("i.fa-eye-slash").parent()[0]
      events = $._data(element, "events")
      expect(events.hasOwnProperty('click')).toBe true
