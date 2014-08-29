TuringEmailApp.Views.Emails ||= {}

class TuringEmailApp.Views.Emails.EmailView extends Backbone.View
  template: JST["backbone/templates/emails/email"]

  events:
    "click a": "toggleStatus"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))
    @hook_email_click()
    return this

  remove: ->
    @$el.remove()

  hook_email_click: ->
    @$el.find(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")

      $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

  toggleStatus: ->
    @model.toggleStatus()
