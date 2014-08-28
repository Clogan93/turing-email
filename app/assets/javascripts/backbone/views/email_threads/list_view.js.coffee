TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: ->
    @collection.on "add", @addOne, this
    @collection.on "reset", @addAll, this

  render: ->
    @addAll()
    this.renderInitialPreviewPane(@collection.first())

  addAll: ->
    @$el.empty()
    @$el.append "<div class='table-responsive'><table class='table' id='email_table'><tbody id='email_table_body'>"
    @collection.forEach @addOne, this

  renderInitialPreviewPane: (email) ->
    @$el.append "<div id='preview_pane'><div id='resize_border'></div><div id='preview_content'><div id='email_content'></div></div></div>"

    emailView = new TuringEmailApp.Views.Emails.EmailView(model: email)
    @$el.find("#email_content").append emailView.render().el
    emailView.bind_collapsed_email_thread_functionality()

  addOne: (email) ->
    emailHeaderView = new TuringEmailApp.Views.EmailThreads.ListItemView(model: email)
    @$el.find("#email_table_body").append emailHeaderView.render().el

  destroy: () ->
    @model.destroy()
    this.remove()

    return false
