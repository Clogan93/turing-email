TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.DraftListView extends TuringEmailApp.Views.EmailThreads.ListView

  addOne: (thread) ->
    draftListItemView = new TuringEmailApp.Views.EmailThreads.DraftListItemView(model: thread)
    @$el.append(draftListItemView.render().el)

  setupDraftComposeView: ->
    @$el.find('a[href^="#email_draft"]').click (event) ->
      event.preventDefault()
      link_components = $(@).attr("href").split("#")
      uid = link_components[link_components.length - 1]
      TuringEmailApp.emailThreadsRouter.showEmailDraft uid
