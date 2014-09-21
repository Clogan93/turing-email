describe "DraftListItemView", ->

  beforeEach ->
    TuringEmailApp.user = new TuringEmailApp.Models.User()
    @emailThread = new TuringEmailApp.Models.EmailThread()
    @emailThread.url = "/api/v1/email_threads"
    @draftListItemView = new TuringEmailApp.Views.EmailThreads.DraftListItemView(
      model: @emailThread
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailThreads.DraftListItemView).toBeDefined()
 
  it "should have the right model", ->
    expect(@draftListItemView.model).toEqual @emailThread

  it "loads the list item template", ->
    expect(@draftListItemView.template).toEqual JST["backbone/templates/email_threads/draft_list_item"]

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("email_thread.fixture.json", "user.fixture.json", true)

      @validUser = @fixtures[1]["valid"]
      @validEmailThread = @fixtures[0]["valid"]

      @server = sinon.fakeServer.create()

      @server.respondWith "GET", "/api/v1/users/current", JSON.stringify(@validUser)
      TuringEmailApp.user.fetch()
      @server.respond()

      @server.respondWith "GET", "/api/v1/email_threads", JSON.stringify(@validEmailThread)
      @emailThread.fetch()
      @server.respond()

      return

    afterEach ->
      @server.restore()

    it "should have the root element be a tr", ->
      expect(@draftListItemView.el.nodeName).toEqual "TR"

    it "should render the from_name attribute", ->
      expect(@draftListItemView.$el.find('td.mail-ontact a').text().trim()).toEqual @emailThread.get("emails")[0].from_name

    it "should render the subject attribute", ->
      expect(@draftListItemView.$el.find('td.mail-subject a').text().trim()).toEqual @emailThread.get("emails")[0].subject

    it "should render the correct link for email thread", ->
      expect(@draftListItemView.$el.find('a').attr("href")).toEqual "#email_draft#" + @emailThread.get("uid")
