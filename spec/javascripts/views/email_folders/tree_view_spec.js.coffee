describe "TreeView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
      app: TuringEmailApp
      demoMode: false
    )

    @treeDiv = $("<div class='email_folders'></div>").appendTo("body")
    @treeView = new TuringEmailApp.Views.EmailFolders.TreeView(
      app: TuringEmailApp
      el: @treeDiv
      collection: @emailFolders
    )

  afterEach ->
    @treeDiv.remove()

    specStopTuringEmailApp()

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
            expect(link).toHaveClass("label-link")
            labelNameComponents = emailFolder.get("name").split("/")
            labelName = labelNameComponents[labelNameComponents.length - 1]
            expect(link).toContainHtml(labelName +
              ' <span class="badge">' + emailFolder.get("num_unread_threads") + '</span>')
          else if labelID is "INBOX"
            badge = link.find("span.inbox-count-badge")
            expect(badge.text()).toEqual("" + emailFolder.get("num_unread_threads"))
          else if labelID is "DRAFT"
            badge = link.find("span.badge")
            expect(badge.text()).toEqual("" + emailFolder.get("num_threads"))
            
      @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
      
      @generateTreeSpy = sinon.spy(@treeView, "generateTree")
      @setupNodesSpy = sinon.spy(@treeView, "setupNodes")
      @selectSpy = sinon.spy(@treeView, "select")

    afterEach ->
      @selectSpy.restore()
      @setupNodesSpy.restore()
      @generateTreeSpy.restore()

    describe "without a selected item", ->
      beforeEach ->
        @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))

      it "generates the tree", ->
        expect(@generateTreeSpy).toHaveBeenCalled()
        
      it "renders the tree view", ->
        @treeDivTest()
        
      it "sets up the nodes", ->
        expect(@setupNodesSpy).toHaveBeenCalled()

      it "does not select the item", ->
        expect(@selectSpy).not.toHaveBeenCalled()

    describe "with a selected item", ->
      beforeEach ->
        @selectSpy.restore()
        @treeView.select(@emailFolders.at(0))
        @selectSpy = sinon.spy(@treeView, "select")
        
        @treeView.render()

      it "generates the tree", ->
        expect(@generateTreeSpy).toHaveBeenCalled()

      it "renders the tree view", ->
        @treeDivTest()

      it "sets up the nodes", ->
        expect(@setupNodesSpy).toHaveBeenCalled()

      it "selects the item", ->
        expect(@selectSpy).toHaveBeenCalledWith(@emailFolders.at(0), silent: true)

    describe "when one of the labels contains no unread emails", ->
      beforeEach ->
        @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
        @emailFolders.models[4].set("num_unread_threads", 0)
        @treeView.render()

      it "assigns the contains-no-unread-emails class to the label with no unread emails", ->
        expect(@treeView.$el.find(".contains-no-unread-emails")).toContainHtml('<span class="badge"></span>')

  describe "#generateTree", ->
    beforeEach ->
      @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
      @emailFolders.add(FactoryGirl.create("EmailFolder.Inbox"))
      @emailFolders.add(FactoryGirl.create("EmailFolder", label_id: "Calendar", name: "Calendar"))
      @emailFolders.add(FactoryGirl.create("EmailFolder", label_id: "Calendar/Google", name: "Calendar/Google"))

      @treeView.generateTree()

    it "generates the correct tree", ->
      expect(@treeView.tree.emailFolder).toEqual null
      expect(_.values(@treeView.tree.children).length).toEqual @emailFolders.length - 1
      expect(_.values(@treeView.tree.children["INBOX"].children).length).toEqual 0

    it "correctly inserts sub-labels in the tree", ->
      expect(_.values(@treeView.tree.children["Calendar"].children).length).toEqual 1
      expect(_.keys(this.treeView.tree.children["Calendar"].children)[0]).toEqual "Google"

  describe "Setup", ->
    describe "#setupNodes", ->
      beforeEach ->
        @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
        @emailFolders.add(FactoryGirl.create("EmailFolder", name: @emailFolders.at(0).get("name") + "/Test"))

      it "binds the click event to the bullet span", ->
        expect(@treeView.$el.find(".bullet-span")).toHandle("click")

      it "binds the click event to the a tags", ->
        expect(@treeView.$el.find("a")).toHandle("click")
        
      describe "when the bullet span is clicked", ->
        it "toggles the labels dropdown associated with that bullet span", ->
          @treeView.$el.find(".bullet_span").each (index, el) ->
            li = $(el).parent().children("ul").children("li")
            $(el).click()
            expect(li).not.toBeVisible()

      describe "when the a tag is clicked", ->
        it "prevents the default link action", ->
          selector = "a"
          spyOnEvent(selector, "click")
          
          @treeView.$el.find("a").first().click()

          expect("click").toHaveBeenPreventedOn(selector)

        it "selects the email folder associated with the link", ->
          spy = sinon.spy(@treeView, "select")
          firstLink = @treeView.$el.find("a").first()
          emailFolder = @treeView.collection.get(firstLink.attr("href"))
          firstLink.click()
          expect(spy).toHaveBeenCalled()
          expect(spy).toHaveBeenCalledWith(emailFolder)
          spy.restore()

  describe "#selectedItem", ->
    describe "without a selected item", ->
      it "should return null", ->
        expect(@treeView.selectedItem()).toEqual null
      
    describe "with a selected item", ->
      beforeEach ->
        @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
        @emailFolder = @emailFolders.at(0)
        @treeView.select(@emailFolder)

      it "selects the item", ->
        expect(@treeView.selectedItem()).toEqual(@emailFolder)

  describe "#select", ->
    beforeEach ->
      @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))

    describe "with a selected item", ->
      beforeEach ->
        @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))

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
        beforeEach ->
          @emailFolderSelectedSpy = sinon.backbone.spy(@treeView, "emailFolderSelected")
          @emailFolderDeselectedSpy = sinon.backbone.spy(@treeView, "emailFolderDeselected")

          @treeView.select(@emailFolder, force: false)
        
        afterEach ->
          @emailFolderSelectedSpy.restore()
          @emailFolderDeselectedSpy.restore()
        
        it "returns immediately", ->
          expect(@emailFolderSelectedSpy).not.toHaveBeenCalled()
          expect(@emailFolderDeselectedSpy).not.toHaveBeenCalled()
          
          expect(@treeView.selectedItem()).toEqual @emailFolder

      describe "when the email folder is the same and there are no options", ->
        beforeEach ->
          @emailFolderSelectedSpy = sinon.backbone.spy(@treeView, "emailFolderSelected")
          @emailFolderDeselectedSpy = sinon.backbone.spy(@treeView, "emailFolderDeselected")

          @treeView.select(@emailFolder)
        
        afterEach ->
          @emailFolderSelectedSpy.restore()
          @emailFolderDeselectedSpy.restore()
          
        it "returns immediately", ->
          expect(@emailFolderSelectedSpy).not.toHaveBeenCalled()
          expect(@emailFolderDeselectedSpy).not.toHaveBeenCalled()
          
          expect(@treeView.selectedItem()).toEqual @emailFolder

      describe "when options silent is true", ->
        beforeEach ->
          @spy = sinon.backbone.spy(@treeView, "emailFolderSelected")

        afterEach ->
          @spy.restore()
          
        it "does not triggers emailFolderSelected", ->  
          @treeView.select(@otherEmailFolder, force: true, silent: true)
          expect(@spy).not.toHaveBeenCalled()

  describe "#updateBadgeCount", ->
    beforeEach ->
      @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
      @emailFolders.add(FactoryGirl.create("EmailFolder.Inbox"))

    describe "when the email folder is the inbox", ->
      beforeEach ->
        @inboxEmailFolder = @treeView.collection.get("INBOX")

      it "updates the inbox count badge", ->
        @treeView.updateBadgeCount @inboxEmailFolder
        expect(@treeView.$el.find('.inbox-count-badge')).toContainHtml(@inboxEmailFolder.badgeString())

    describe "when the email folder is not the inbox", ->
      beforeEach ->
        @emailFolderID = @emailFolders.at(0).get("label_id")
        @nonInboxEmailFolder = @treeView.collection.get(@emailFolderID)

      it "updates the email folder's badge count", ->
        @treeView.updateBadgeCount @nonInboxEmailFolder
        expect(@treeView.$el.find('a[href="' + @emailFolderID + '"]>.badge').html(@nonInboxEmailFolder.badgeString()))

  describe "#emailFolderUnreadCountChanged", ->
    beforeEach ->
      @emailFolders.reset(FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE))
      @emailFolder = @emailFolders.models[0]

    it "updates the badge count", ->
      spy = sinon.spy(@treeView, "updateBadgeCount")
      @treeView.emailFolderUnreadCountChanged TuringEmailApp, @emailFolder
      expect(spy).toHaveBeenCalled()
      expect(spy).toHaveBeenCalledWith(@emailFolder)
      spy.restore()
