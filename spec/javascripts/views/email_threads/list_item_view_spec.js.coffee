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

    # TODO write tests for the select and deselect functions.
    # TODO write tests for detecting the backbone events.

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
      expect(@listItemView.$el.find('td.mail-contact').text().trim()).toEqual @emailThread.get("emails")[0].from_name
      expect(@listItemView.$el.find('td.mail-subject').text().trim()).toEqual @emailThread.get("emails")[0].subject
      # TODO test date

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

    it "bind click handlers to tds", ->
      expect(@listItemView.$el.find('td.check-mail')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-contact')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-subject')).toHandle("click")
      expect(@listItemView.$el.find('td.mail-date')).toHandle("click")

      # TODO make a backbone spy to test the backbone event is triggered upon click.

  describe "#setupCheckbox", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    # it "calls iCheck on each checkbox", ->
    #   @spy = sinon.spy(@listItemView.$el.find(".i-checks"), "iCheck")
    #   @listItemView.setupCheckbox()
    #   expect(@spy).toHaveBeenCalled()

    it "binds click events to the checkboxes", ->
      @listItemView.setupCheckbox()
      expect(@listItemView.$el.find("div.icheckbox_square-green ins")).toHandle("click")

    it "calls toggleSelect when a checkbox is clicked", ->
      @listItemView.setupCheckbox()
      @spy = sinon.spy(@listItemView, "toggleSelect")
      @listItemView.$el.find("div.icheckbox_square-green ins").click()
      expect(@spy).toHaveBeenCalled()

  # describe "#toggleSelect", ->
  #   beforeEach ->
  #     @emailThread.fetch()
  #     @server.respond()

  #   it "selects the checkbox when it is checked", ->
  #     @selectSpy = sinon.spy(@listItemView, "select")
  #     @listItemView.toggleSelect()
  #     expect(@selectSpy).toHaveBeenCalled()

  #   it "deselects the checkbox when it is not checked", ->
  #     return

  describe "#select", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "adds the checked_email_thread class", ->
      @listItemView.$el.removeClass("checked_email_thread")
      expect(@listItemView.$el).not.toHaveClass("checked_email_thread")
      @listItemView.select()
      expect(@listItemView.$el).toHaveClass("checked_email_thread")

  describe "#deselect", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "removes the checked_email_thread class", ->
      @listItemView.$el.addClass("checked_email_thread")
      expect(@listItemView.$el).toHaveClass("checked_email_thread")
      @listItemView.deselect()
      expect(@listItemView.$el).not.toHaveClass("checked_email_thread")

  describe "#highlight", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "removes the read class", ->
      @listItemView.$el.addClass("read")
      expect(@listItemView.$el).toHaveClass("read")
      @listItemView.highlight()
      expect(@listItemView.$el).not.toHaveClass("read")

    it "removes the unread class", ->
      @listItemView.$el.addClass("unread")
      expect(@listItemView.$el).toHaveClass("unread")
      @listItemView.highlight()
      expect(@listItemView.$el).not.toHaveClass("unread")

    it "adds the currently_being_read class", ->
      @listItemView.$el.removeClass("currently_being_read")
      expect(@listItemView.$el).not.toHaveClass("currently_being_read")
      @listItemView.highlight()
      expect(@listItemView.$el).toHaveClass("currently_being_read")

  describe "#unhighlight", ->
    beforeEach ->
      @emailThread.fetch()
      @server.respond()

    it "removes the currently_being_read class", ->
      @listItemView.$el.addClass("currently_being_read")
      expect(@listItemView.$el).toHaveClass("currently_being_read")
      @listItemView.unhighlight()
      expect(@listItemView.$el).not.toHaveClass("currently_being_read")

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
