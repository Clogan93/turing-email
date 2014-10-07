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

    describe "when one of the labels contains no unread emails", ->
      beforeEach ->
        @emailFolders.fetch()
        @server.respond()
        @emailFolders.models[4].set("num_unread_threads", 0)
        @treeView.render()

      it "assigns the contains_no_unread_emails class to the label with no unread emails", ->
        expect(@treeView.$el.find(".contains_no_unread_emails")).toContainHtml('<span class="badge"></span>')

  describe "#generateTree", ->
    beforeEach ->
      @emailFolders.fetch()
      @server.respond()

    it "generates the correct tree", ->
      @treeView.generateTree()
      expect(@treeView.tree.emailFolder).toEqual null
      expect(_.values(@treeView.tree.children).length).toEqual 9
      expect(_.values(@treeView.tree.children["INBOX"].children).length).toEqual 0

    it "correctly inserts sub-labels in the tree", ->
      expect(_.values(@treeView.tree.children["Calendar"].children).length).toEqual 1
      expect(_.keys(this.treeView.tree.children["Calendar"].children)[0]).toEqual "Google"

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

  describe "#selectedItem", ->

    describe "without a selected item", ->
      beforeEach ->
        @emailFolders.fetch()
        @server.respond()

      it "should return null", ->
        expect(@treeView.selectedItem()).toEqual null
      
    describe "with a selected item", ->
      beforeEach ->
        @emailFolder = new TuringEmailApp.Models.EmailFolder()
        @treeView.select(@emailFolder)

        @emailFolders.fetch()
        @server.respond()

      it "selects the item", ->
        expect(@treeView.selectedItem()).toEqual @emailFolder

  describe "#select", ->
    beforeEach ->
      @emailFolders.fetch()
      @server.respond()

    describe "with a selected item", ->
      beforeEach ->
        @emailFolders.fetch()
        @server.respond()

        @emailFolder = @emailFolders.models[0]
        @otherEmailFolder = @emailFolders.models[1]
        @treeView.select(@emailFolder, force: true)

      it "deselects the item", ->
        spy = sinon.backbone.spy(@treeView, "emailFolderDeselected")
        @treeView.select(@otherEmailFolder, force: true)
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(@treeView, @emailFolder)
        spy.restore()

      it "updates the tree view's selected item", ->
        expect(@treeView.selectedItem()).toEqual @emailFolder
        @treeView.select(@otherEmailFolder, force: true)
        expect(@treeView.selectedItem()).toEqual @otherEmailFolder

      it "triggers emailFolderSelected", ->
        spy = sinon.backbone.spy(@treeView, "emailFolderSelected")
        @treeView.select(@otherEmailFolder, force: true)
        expect(spy).toHaveBeenCalled()
        expect(spy).toHaveBeenCalledWith(@treeView, @otherEmailFolder)
        spy.restore()

      describe "when the email folder is the same and the option force is false", ->

        it "returns immediately", ->
          emailFolderSelectedSpy = sinon.backbone.spy(@treeView, "emailFolderSelected")
          emailFolderDeselectedSpy = sinon.backbone.spy(@treeView, "emailFolderDeselected")
          @treeView.select(@emailFolder, force: false)
          expect(emailFolderSelectedSpy).not.toHaveBeenCalled()
          expect(emailFolderDeselectedSpy).not.toHaveBeenCalled()
          expect(@treeView.selectedItem()).toEqual @emailFolder
          emailFolderSelectedSpy.restore()
          emailFolderDeselectedSpy.restore()

      describe "when the email folder is the same and there are no options", ->

        it "returns immediately", ->
          emailFolderSelectedSpy = sinon.backbone.spy(@treeView, "emailFolderSelected")
          emailFolderDeselectedSpy = sinon.backbone.spy(@treeView, "emailFolderDeselected")
          @treeView.select(@emailFolder)
          expect(emailFolderSelectedSpy).not.toHaveBeenCalled()
          expect(emailFolderDeselectedSpy).not.toHaveBeenCalled()
          expect(@treeView.selectedItem()).toEqual @emailFolder
          emailFolderSelectedSpy.restore()
          emailFolderDeselectedSpy.restore()

      describe "when options silent is true", ->

        it "does not triggers emailFolderSelected", ->
          spy = sinon.backbone.spy(@treeView, "emailFolderSelected")
          @treeView.select(@otherEmailFolder, force: true, silent: true)
          expect(spy).not.toHaveBeenCalled()
          spy.restore()

  describe "#updateBadgeCount", ->
    beforeEach ->
      @emailFolders.fetch()
      @server.respond()

    describe "when the email folder is the inbox", ->
      beforeEach ->
        @inboxEmailFolder = @treeView.collection.getEmailFolder "INBOX"

      it "updates the inbox count badge", ->
        @treeView.updateBadgeCount @inboxEmailFolder
        expect(@treeView.$el.find('.inbox_count_badge')).toContainHtml(@inboxEmailFolder.badgeString())

    describe "when the email folder is not the inbox", ->
      beforeEach ->
        @emailFolderID = "Label_119"
        @nonInboxEmailFolder = @treeView.collection.getEmailFolder @emailFolderID

      it "updates the email folder's badge count", ->
        @treeView.updateBadgeCount @nonInboxEmailFolder
        expect(@treeView.$el.find('a[href="' + @emailFolderID + '"]>.badge').html(@nonInboxEmailFolder.badgeString()))

  describe "#emailFolderUnreadCountChanged", ->
    beforeEach ->
      @emailFolders.fetch()
      @server.respond()
      @emailFolder = @emailFolders.models[0]

    it "updates the badge count", ->
      spy = sinon.spy(@treeView, "updateBadgeCount")
      @treeView.emailFolderUnreadCountChanged TuringEmailApp, @emailFolder
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith(@emailFolder)
