TuringEmailApp.Views.Emails ||= {}

class TuringEmailApp.Views.Emails.EmailThreadView extends Backbone.View
  template: JST["backbone/templates/email_threads/email_thread"]

  events:
    "click a": "toggleStatus"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @bindEmailClick()
    return this

  remove: ->
    @$el.remove()

  bindEmailClick: ->
    @$el.find(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")

      $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

  toggleStatus: ->
    @model.toggleStatus()
