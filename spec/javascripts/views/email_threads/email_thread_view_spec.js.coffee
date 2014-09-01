describe "EmailThreadView", ->

  beforeEach ->
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
