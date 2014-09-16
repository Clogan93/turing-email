TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.DraftListView extends TuringEmailApp.Views.EmailThreads.ListView

  addOne: (thread) ->
    draftListItemView = new TuringEmailApp.Views.EmailThreads.DraftListItemView(model: thread)
    @$el.append(draftListItemView.render().el)
