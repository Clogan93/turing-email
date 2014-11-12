TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmailTrackersView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/app/email_trackers"]
  
  render: ->
    @$el.html(@template(emailTrackers: @collection.toJSON()))
    
    return this
