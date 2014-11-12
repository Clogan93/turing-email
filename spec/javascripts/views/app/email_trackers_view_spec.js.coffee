describe "EmailTrackersView", ->
  beforeEach ->
    @collection = new Backbone.Collection([{}])
    @emailTrackersView = new TuringEmailApp.Views.App.EmailTrackersView(collection: @collection)

  it "has the right template", ->
    expect(@emailTrackersView.template).toEqual JST["backbone/templates/app/email_trackers"]
