describe "ListItemView", ->

  beforeEach ->
    TuringEmailApp.user = new TuringEmailApp.Models.User()
    @emailThread = new TuringEmailApp.Models.EmailThread()
    @emailThread.url = "/api/v1/email_threads"
    @listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(
      model: @emailThread
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailThreads.ListItemView).toBeDefined()
 
  it "should have the right model", ->
    expect(@listItemView.model).toEqual @emailThread

  it "loads the list item template", ->
    expect(@listItemView.template).toEqual JST["backbone/templates/email_threads/list_item"]

  describe "when render is called", ->

    beforeEach ->
      @fixtures = fixture.load("email_thread.fixture.json", "user.fixture.json", true)

      @validEmailThread = @fixtures[0]["valid"]
      @validUser = @fixtures[1]["valid"]

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
      expect(@listItemView.el.nodeName).toEqual "TR"

    it "should render the from_name attribute", ->
      expect(@listItemView.$el.find('.email_from_column').text().trim()).toEqual @emailThread.get("emails")[0].from_name

    it "should render the subject attribute", ->
      expect(@listItemView.$el.find('.email_subject_column a').text().trim()).toEqual @emailThread.get("emails")[0].subject

    it "should render the snippet attribute", ->
      expect(@listItemView.$el.find('.email_snippet').text().trim()).toEqual @emailThread.get("emails")[0].snippet

    it "should render the correct link for email thread", ->
      expect(@listItemView.$el.find('a').attr("href")).toEqual "#email_thread#" + @emailThread.get("uid")
