describe "EmailThreadView", ->

  beforeEach ->
    TuringEmailApp.user = new TuringEmailApp.Models.User()
    @emailThread = new TuringEmailApp.Models.EmailThread()
    @emailThread.url = "/api/v1/email_threads"
    @emailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: @emailThread
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailThreads.EmailThreadView).toBeDefined()
 
   it "should have the right model", ->
    expect(@emailThreadView.model).toEqual @emailThread

  it "loads the list item template", ->
    expect(@emailThreadView.template).toEqual JST["backbone/templates/email_threads/email_thread"]

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

    it "should have the root element be a div", ->
      expect(@emailThreadView.el.nodeName).toEqual "DIV"

    it "should render the subject attribute", ->
      expect(@emailThreadView.$el.find('#email_subject').text().trim()).toEqual @emailThread.get("emails")[0].subject

    it "should render the attributes of all the email threads", ->
      #Set up lists
      fromNames = []
      snippets = []
      textParts = []

      #Collect Attributes from the rendered DOM.
      @emailThreadView.$el.find('.email_information .col-md-3').each ->
        fromNames.push $(this).text().trim()
      @emailThreadView.$el.find('.email_information .col-md-4').each ->
        snippets.push $(this).text().trim()
      @emailThreadView.$el.find('.email_body .col-md-11').each ->
        textParts.push $(this).text().trim()

      #Run expectations
      for email, index in @emailThread.get("emails")
        expect(fromNames[index]).toEqual email.from_name
        expect(snippets[index]).toEqual email.snippet
        expect(textParts[index]).toEqual email.text_part
