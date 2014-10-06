describe "TreeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection()

    @treeDiv = $("<div />", {id: "email_folders"}).appendTo("body")
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
      @treeDivTest = ->
        expect(@treeDiv).toBeVisible()

        for emailFolder in @emailFolders.models
          labelID = emailFolder.get("label_id")
          link = @treeDiv.find("#" + labelID)

          if emailFolder.get("label_type") == "user"
            expect(link).toBeVisible()
            expect(link).toHaveClass("label_link")
            labelNameComponents = emailFolder.get("name").split("/")
            labelName = labelNameComponents[labelNameComponents.length - 1]
            expect(link).toContainHtml(labelName +
              ' <span class="badge">' + emailFolder.get("num_unread_threads") + '</span>')
          else if labelID is "INBOX"
            badge = link.find("span.inbox_count_badge")
            expect(badge.text()).toEqual("" + emailFolder.get("num_unread_threads"))
          else if labelID is "DRAFT"
            badge = link.find("span.badge")
            expect(badge.text()).toEqual("" + emailFolder.get("num_threads"))
      
      @selectSpy = sinon.spy(@treeView, "select")

    afterEach ->
      @selectSpy.restore()

    describe "without a selected item", ->
      beforeEach ->
        @emailFolders.fetch()
        @server.respond()

      it "renders the tree view", ->
        @treeDivTest()

      it "does not select the item", ->
        expect(@selectSpy).not.toHaveBeenCalled()

    describe "with a selected item", ->
      beforeEach ->
        @emailFolder = new TuringEmailApp.Models.EmailFolder()
        @treeView.select(@emailFolder)

        @emailFolders.fetch()
        @server.respond()

      it "renders the tree view", ->
        @treeDivTest()

      it "selects the item", ->
        expect(@selectSpy).toHaveBeenCalledWith(@emailFolder)

  describe "#generateTree", ->
    # TODO write tests

  describe "Setup", ->
    describe "#setupNodes", ->
      beforeEach ->
        @emailFolders.fetch()
        @server.respond()

      it "binds the click event to the bullet span", ->
        expect(@treeView.$el.find(".bullet_span")).toHandle("click")

      describe "when the bullet span is clicked", ->

        it "toggles the labels dropdown associated with that bullet span", ->
          @treeView.$el.find(".bullet_span").each (index, el) ->
            li = $(el).parent().children("ul").children("li")
            $(el).click()
            expect(li).not.toBeVisible()

      it "binds the click event to the a tags", ->
        expect(@treeView.$el.find("a")).toHandle("click")

      describe "when the a tag is clicked", ->

        it "prevents the default link action", ->
          selector = "a"
          spyOnEvent(selector, "click")
          
          @treeView.$el.find("a").first().click()

          expect("click").toHaveBeenPreventedOn(selector)

        it "selects the email folder associated with the link", ->
          spy = sinon.spy(@treeView, "select")
          firstLink = @treeView.$el.find("a").first()
          emailFolder = @treeView.collection.getEmailFolder(firstLink.attr("href"))
          firstLink.click()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailFolder)

  describe "#select", ->
    return
