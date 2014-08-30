TuringEmailApp.Views.Emails ||= {}

class TuringEmailApp.Views.Emails.EmailThreadView extends Backbone.View
  template: JST["backbone/templates/email_threads/email_thread"]

  events:
    "click a": "setSeen"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    @$el.html(@template(@model.toJSON()))
    @bindEmailClick()
    return this

  bindEmailClick: ->
    @$el.find(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")

      $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

  setSeen: ->
    @model.setSeen()
