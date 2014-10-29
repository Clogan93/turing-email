describe "InstalledPanelApp", ->
  beforeEach ->
    installedAppJSON = FactoryGirl.create("InstalledPanelApp")
    @installedPanelApp = TuringEmailApp.Models.InstalledApps.InstalledApp.CreateFromJSON(installedAppJSON)
    
  describe "#run", ->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @data = "<head></head><body>hi</body>"
      @server.respondWith "POST", @installedPanelApp.get("app").callback_url, @data

      @iframe = $("<iframe></iframe>").appendTo("body")
      
      emailThreadAttributes = FactoryGirl.create("EmailThread")
      @emailThread = new TuringEmailApp.Models.EmailThread(emailThreadAttributes.toJSON(),
        app: TuringEmailApp
        emailThreadUID: emailThreadAttributes.uid
      )
      
      @installedPanelApp.run(@iframe, @emailThread)
      
    afterEach ->
      @iframe.remove()
      
      @server.restore()
        
    it "posts the request", ->
      expect(@server.requests.length).toEqual(1)

      request = @server.requests[0]
      expect(request.method).toEqual("POST")
      expect(request.url).toEqual(@installedPanelApp.get("app").callback_url)
      expect(request.requestBody).toEqual($.param({email_thread: @emailThread.toJSON()}, false))
      
    it "updates the iframe on success", ->
      @server.respond()
      expect(@iframe.contents().find("html").html()).toEqual(@data)