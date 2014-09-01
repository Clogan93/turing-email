describe "TreeView", ->

  beforeEach ->
    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()
    @emailFoldersTreeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      collection: @emailFolders
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailFolders.TreeView).toBeDefined()

  it "should have the right collection", ->
    expect(@emailFoldersTreeView.collection).toEqual @emailFolders

  it "loads the Tree template", ->
    expect(@emailFoldersTreeView.template).toEqual JST["backbone/templates/email_folders/tree"]

  describe "when render is called", ->

    beforeEach ->
      #Load fixtures
      @fixtures = fixture.load("email_folders.fixture.json", true)

      @validEmailFolders = @fixtures[0]["valid"]
      @additional_email = @fixtures[0]["additional"]

      @server = sinon.fakeServer.create()
      @server.respondWith "GET", "/api/v1/email_folders", JSON.stringify(@validEmailFolders)

      @emailFolders.fetch()
      @server.respond()

    afterEach ->
      @server.restore()

    it "should have the root element be a div", ->
      expect(@emailFoldersTreeView.render().el.nodeName).toEqual "DIV"

    it "should render the right number of children", ->
      expect(@emailFoldersTreeView.$el.children().length).toEqual 3

    it "should render each of the email folders with label_type show", ->
      validate_tree @emailFoldersTreeView, @emailFolders

    it "should render the correct link for email folders with label_type show", ->
      links = []
      @emailFoldersTreeView.$el.find('a').each (index, element) ->
        links.push $(this).attr("href")
      
      for emailFolder in @emailFolders.models
        if emailFolder.get("label_type") is "user"
          expect(links).toContain "#folder#" + emailFolder.get("label_id")

    it "should render when an element is added to the collection", ->
      @emailFolders.add @additional_email

      expect(@emailFoldersTreeView.$el.children().length).toEqual 4

      validate_tree @emailFoldersTreeView, @emailFolders

window.validate_tree = (emailFoldersTreeView, emailFolders) ->
  element_names = []
  element_unread_counts = []
  emailFoldersTreeView.$el.find('a').each (index, element) ->
    elements = $(this).text().trim().split(" ")
    element_names.push elements[0]
    element_unread_counts.push elements[1]
  
  for emailFolder in emailFolders.models
    if emailFolder.get("label_type") is "user"
      expect(element_names).toContain emailFolder.get("name")
      expect(element_unread_counts).toContain emailFolder.get("num_unread_threads").toString()
