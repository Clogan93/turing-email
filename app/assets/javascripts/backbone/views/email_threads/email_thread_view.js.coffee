TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.EmailThreadView extends Backbone.View
  template: JST["backbone/templates/email_threads/email_thread"]

  events:
    "click a": "setSeen"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    $("#email-folder-mail-header").hide()
    @$el.html(@template(@model.toJSON()))

    @render_genie_report()

    @bindEmailClick()
    return 

  render_genie_report: ->
    for email, index in @model.get("emails")
      if email.subject is "Turing Email - Your daily Genie Report!"
        @$el.find("#email_iframe" + index.toString()).contents().find("body").append(email.html_part);
        body_height = @$el.find("#email_iframe" + index.toString()).contents().find("body").css("height")
        body_height_adjusted = parseInt(body_height.replace("px","")) + 25
        body_height_adjusted_string = body_height_adjusted.toString() + "px"
        @$el.find("#email_iframe" + index.toString()).css("height", body_height_adjusted_string)

        @$el.find("#email_iframe" + index.toString()).contents().find("body").find("a").click (event) ->
          event.preventDefault()
          alert $(@).attr("href")

  bindEmailClick: ->
    @$el.find(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")

      $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

  setSeen: ->
    @model.setSeen()
