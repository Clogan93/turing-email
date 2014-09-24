describe "EmailDraft", ->
  beforeEach ->
    @url = "/api/v1/email_accounts/drafts" 
    @sendDraftURL = "/api/v1/email_accounts/send_draft"
    
    @emailDraft = new TuringEmailApp.Models.EmailDraft()

    @server = sinon.fakeServer.create()
    @server.respondWith "POST", @sendDraftURL, JSON.stringify({})

  afterEach ->
    @server.restore()

  it "should have the right url", ->
    expect(@emailDraft.url).toEqual @url

  describe "#sendDraft", ->
    beforeEach ->
      @emailDraft.tos = ["test@turinginc.com"]
      
      @emailDraft.sendDraft()
      @server.respond()
      
    it "should send the draft", ->
      expect(@server.requests.length).toEqual 1
      request = @server.requests[0]
      expect(request.method).toEqual "POST"
      expect(request.url).toEqual @sendDraftURL
