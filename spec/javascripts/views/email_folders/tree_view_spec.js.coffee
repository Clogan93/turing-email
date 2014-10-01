describe "TreeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()

    @treeDiv = $("<div />", {id: "email_folders"}).appendTo('body')
    @treeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      app: TuringEmailApp
      el: @treeDiv
      collection: @emailFolders
    )

    emailFoldersFixtures = fixture.load("email_folders.fixture.json")
    @validEmailFoldersFixture = emailFoldersFixtures[0]["valid"]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @emailFolders.url, JSON.stringify(@validEmailFoldersFixture)

  afterEach ->
    @server.restore()
    @treeDiv.remove()

  it "has the right template", ->
    expect(@treeView.template).toEqual JST["backbone/templates/email_folders/tree"]

  describe "#render", ->
    beforeEach ->
      @emailFolders.fetch()
      @server.respond()

    it "renders the tree view", ->
      expect(@treeDiv).toBeVisible()

      for emailFolder in @emailFolders.models
        continue if emailFolder.get("label_type") != "user"
        
        link = @treeDiv.find("#" + emailFolder.get("label_id"))
        expect(link).toBeVisible()
        expect(link).toHaveClass("label_link")
        expect(link).toContainHtml(emailFolder.get("name") +
                                   ' <span class="badge">' + emailFolder.get("num_unread_threads") + '</span>')

  describe "#generateTree", ->
    # TODO write tests
  
  describe "#select", ->
    beforeEach ->
      @emailFolders.fetch()
      @server.respond()

      @firstFolder = @emailFolders.models[0]
      @secondFolder = @emailFolders.models[3]
      @firstLabelID = @firstFolder.get("label_id")
      @secondLabelID = @secondFolder.get("label_id")

      @firstLabelDiv = @treeDiv.find('a[href="#email_folder/' + @firstLabelID + '"]')
      @secondLabelDiv = @treeDiv.find('a[href="#email_folder/' + @secondLabelID + '"]')

    it "changes the currently selected folder", ->
      expect(@treeView.selectedItem()).toBeUndefined()
      
      @treeView.select(@firstFolder)
      expect(@treeView.selectedItem()).toEqual(@firstFolder)
      expect(@firstLabelDiv).toHandle("click")
  
      @treeView.select(@secondFolder)
      expect(@treeView.selectedItem()).toEqual(@secondFolder)
      expect(@secondLabelDiv).toHandle("click")
      expect(@firstLabelDiv).not.toHandle("click")

      @secondLabelDiv.click()
      expect("click").toHaveBeenPreventedOn("#" + @secondLabelID)
