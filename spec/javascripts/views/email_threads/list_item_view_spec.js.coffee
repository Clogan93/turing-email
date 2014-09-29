describe "ListItemView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailThreadFixtures = fixture.load("email_thread.fixture.json");
    @validEmailThreadFixture = emailThreadFixtures[0]["valid"]

    @emailThread = new TuringEmailApp.Models.EmailThread(undefined, emailThreadUID: @validEmailThreadFixture["uid"])
    @listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(
      model: @emailThread
    )

    @server = sinon.fakeServer.create()

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", @emailThread.url, JSON.stringify(@validEmailThreadFixture)

  afterEach ->
    @server.restore()

  it "has the right template", ->
    expect(@listItemView.template).toEqual JST["backbone/templates/email_threads/list_item"]

  describe "#render", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()
      
    it "renders the list item", ->
      expect(@listItemView.el.nodeName).toEqual "TR"
      expect(@listItemView.el).toHaveCss({cursor: "pointer"})

      expect(@listItemView.el).toContain("td.check-mail")
      expect(@listItemView.$el.find('td.mail-contact').text().trim()).toEqual @emailThread.fromPreview()
      expect(@listItemView.$el.find('td.mail-subject').text().trim()).toEqual @emailThread.subjectPreview()
      expect(@listItemView.$el.find('td.mail-date').text().trim()).toEqual @emailThread.datePreview()

  describe "#addedToDOM", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "calls setupCheckbox when addedToDOM is called", ->
      @spy = sinon.spy(@listItemView, "setupCheckbox")
      @listItemView.addedToDOM()
      expect(@spy).toHaveBeenCalled()

  describe "#setupClick", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

      @tdCheckMail = @listItemView.$el.find('td.check-mail')

    it "bind click handlers to tds", ->
      expect(@tdCheckMail).toHandle("click")
      expect(@listItemView.$el.find('td.mail-contact')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-subject')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-date')).toHandle("click")

    describe "when clicked", ->

      it "triggers click", ->
        spy = sinon.backbone.spy(@listItemView, "click")
        @tdCheckMail.click()
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe "#setupCheckbox", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "calls iCheck on each checkbox", ->
      @listItemView.setupCheckbox()
      diviCheck = @listItemView.$el.find("div.icheckbox_square-green")
      expect(diviCheck).toHaveClass("icheckbox_square-green")
      expect(diviCheck).toContain("input.i-checks")
      expect(diviCheck).toContain("ins.iCheck-helper")

    it "binds click events to the checkboxes", ->
      @listItemView.setupCheckbox()
      expect(@listItemView.$el.find("div.icheckbox_square-green ins")).toHandle("click")

    describe "when a checkbox is clicked", ->
      beforeEach ->
        @listItemView.setupCheckbox()

      it "calls updateSelectionStyles", ->
        @spy = sinon.spy(@listItemView, "updateSelectionStyles")
        @listItemView.$el.find("div.icheckbox_square-green ins").click()
        expect(@spy).toHaveBeenCalled()

      describe "when checked", ->
        beforeEach ->
          @listItemView.select()

        it "triggers deselected", ->
          spy = sinon.backbone.spy(@listItemView, "deselected")
          @listItemView.$el.find("div.icheckbox_square-green ins").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

      describe "when unchecked", ->
        beforeEach ->
          @listItemView.deselect()

        it "triggers selected", ->
          spy = sinon.backbone.spy(@listItemView, "selected")
          @listItemView.$el.find("div.icheckbox_square-green ins").click()
          expect(spy).toHaveBeenCalled()
          spy.restore()

  describe "#isChecked", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

      @listItemView.setupCheckbox()

    it "returns false when the checkbox is not checked", ->
      expect(@listItemView.isChecked()).toBeFalsy()

    it "returns true when the checkbox is checked", ->
      @listItemView.select()
      expect(@listItemView.isChecked()).toBeTruthy()

  describe "#updateSelectionStyles", ->

    beforeEach ->
      @emailThread.fetch()
      @server.respond()

      @listItemView.setupCheckbox()

    describe "when selected", ->
      beforeEach ->
        @listItemView.select()
        @listItemView.updateSelectionStyles()
      
      it "adds the selected styles", ->
        expect(@listItemView.$el).toHaveClass("checked_email_thread")

    describe "when deselected", ->
      beforeEach ->
        @listItemView.deselect()
        @listItemView.updateSelectionStyles()
      
      it "removes the selected styles", ->
        expect(@listItemView.$el).not.toHaveClass("checked_email_thread")

  describe "#toggleSelect", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

      @listItemView.setupCheckbox()

    describe "when selected", ->
      beforeEach ->
        @listItemView.select()

      it "calls deselect", ->
        spy = sinon.spy(@listItemView, "deselect")
        @listItemView.toggleSelect()
        expect(spy).toHaveBeenCalled()

    describe "when deselected", ->
      beforeEach ->
        @listItemView.deselect()

      it "calls select", ->
        spy = sinon.spy(@listItemView, "select")
        @listItemView.toggleSelect()
        expect(spy).toHaveBeenCalled()

  describe "#select", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()
      @listItemView.addedToDOM()

    it "adds the checked_email_thread class", ->
      @listItemView.$el.removeClass("checked_email_thread")
      expect(@listItemView.$el).not.toHaveClass("checked_email_thread")
      @listItemView.select()
      expect(@listItemView.$el).toHaveClass("checked_email_thread")

    it "triggers selected", ->
      spy = sinon.backbone.spy(@listItemView, "selected")
      @listItemView.select()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#deselect", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()
      @listItemView.addedToDOM()

    it "removes the checked_email_thread class", ->
      @listItemView.$el.addClass("checked_email_thread")
      expect(@listItemView.$el).toHaveClass("checked_email_thread")
      @listItemView.deselect()
      expect(@listItemView.$el).not.toHaveClass("checked_email_thread")

    it "triggers deselected", ->
      spy = sinon.backbone.spy(@listItemView, "deselected")
      @listItemView.deselect()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#highlight", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "adds the currently_being_read class", ->
      @listItemView.$el.removeClass("currently_being_read")
      expect(@listItemView.$el).not.toHaveClass("currently_being_read")
      @listItemView.highlight()
      expect(@listItemView.$el).toHaveClass("currently_being_read")

    it "triggers highlight", ->
      spy = sinon.backbone.spy(@listItemView, "highlight")
      @listItemView.highlight()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#unhighlight", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "removes the currently_being_read class", ->
      @listItemView.$el.addClass("currently_being_read")
      expect(@listItemView.$el).toHaveClass("currently_being_read")
      @listItemView.unhighlight()
      expect(@listItemView.$el).not.toHaveClass("currently_being_read")

    it "triggers unhighlight", ->
      spy = sinon.backbone.spy(@listItemView, "unhighlight")
      @listItemView.unhighlight()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#markRead", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "removes the unread class", ->
      @listItemView.$el.addClass("unread")
      expect(@listItemView.$el).toHaveClass("unread")
      @listItemView.markRead()
      expect(@listItemView.$el).not.toHaveClass("unread")

    it "adds the read class", ->
      @listItemView.$el.removeClass("read")
      expect(@listItemView.$el).not.toHaveClass("read")
      @listItemView.markRead()
      expect(@listItemView.$el).toHaveClass("read")

    it "triggers markRead", ->
      spy = sinon.backbone.spy(@listItemView, "markRead")
      @listItemView.markRead()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe "#markUnread", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "removes the read class", ->
      @listItemView.$el.addClass("read")
      expect(@listItemView.$el).toHaveClass("read")
      @listItemView.markUnread()
      expect(@listItemView.$el).not.toHaveClass("read")

    it "adds the unread class", ->
      @listItemView.$el.removeClass("unread")
      expect(@listItemView.$el).not.toHaveClass("unread")
      @listItemView.markUnread()
      expect(@listItemView.$el).toHaveClass("unread")

    it "triggers markUnread", ->
      spy = sinon.backbone.spy(@listItemView, "markUnread")
      @listItemView.markUnread()
      expect(spy).toHaveBeenCalled()
      spy.restore()
