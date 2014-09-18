describe "EmailThreadsRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.EmailThreadsRouter
    @routeSpy = sinon.spy()
    try
      TuringEmailApp.start()

  it "has a email_thread route and points to the showEmailThread method", ->
    expect(@router.routes["email_thread#:uid"]).toEqual "showEmailThread"

  it "Has the right number of routes", ->
    expect(_.size(@router.routes)).toEqual 2
