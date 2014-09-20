describe "EmailFoldersRouter", ->

  beforeEach ->
    @router = new TuringEmailApp.Routers.EmailFoldersRouter()
    @routeSpy = sinon.spy()
    try
      Backbone.history.start
        silent: true

  it "has a folder route and points to the showFolder method", ->
    expect(@router.routes["folder#DRAFT"]).toEqual "showDraftFolder"
    expect(@router.routes["folder#:folder_id"]).toEqual "showFolder"

  it "Has the right number of routes", ->
    expect(_.size(@router.routes)).toEqual 2

  it "fires the showFolder route with folder", ->
    @router.bind "route:showFolder", @routeSpy
    @router.navigate "folder#INBOX",
      trigger: true
    console.log @routeSpy
    expect(@routeSpy).toHaveBeenCalledOnce()
    expect(@routeSpy).toHaveBeenCalledWith("INBOX")
    return
