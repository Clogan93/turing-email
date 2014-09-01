describe "ListView", ->

  beforeEach ->
    @emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection()
    @emailThreadView = new TuringEmailApp.Views.EmailThreads.ListView(
      collection: @emailThreads
    )

  it "should be defined", ->
    expect(TuringEmailApp.Views.EmailThreads.ListView).toBeDefined()
 
   it "should have the right collection", ->
    expect(@emailThreadView.collection).toEqual @emailThreads
