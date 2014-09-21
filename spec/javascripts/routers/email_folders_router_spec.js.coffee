describe "EmailFoldersRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.EmailFoldersRouter()
    @routeSpy = sinon.spy()
    try
      Backbone.history.start
        pushState: false
        silent: true

  it "has a folder route and points to the showFolder method", ->
    expect(@router.routes["folder#DRAFT"]).toEqual "showDraftFolder"
    expect(@router.routes["folder#:folder_id"]).toEqual "showFolder"

  it "Has the right number of routes", ->
    expect(_.size(@router.routes)).toEqual 2
