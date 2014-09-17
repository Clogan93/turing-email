TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListView extends Backbone.View
  initialize: ->
    @listenTo(@collection, "add", @addOne)
    @listenTo(@collection, "reset", @addAll)
    @listenTo(@collection, "destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    @addAll()
    return this

  addOne: (thread) ->
    listItemView = new TuringEmailApp.Views.EmailThreads.ListItemView(model: thread)
    @$el.append(listItemView.render().el)

  addAll: ->
    @$el.empty()
    @collection.forEach(@addOne, this)
    @moveReportToTop()

    $(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

    @addKeyboardShortcutHighlight()

    if TuringEmailApp.userSettings.get("split_pane_mode") is "horizontal"
      $("#preview_panel").show()
      @renderEmailPreview()

  addKeyboardShortcutHighlight: ->
    $("#email_table_body tr:nth-child(1)").addClass("email_thread_highlight")

  moveReportToTop: ->
    report_email = null
    @$el.find("td.mail-ontact a").each ->
      text_value = $(@).text()
      
      if text_value is "Turing Email"
        report_email = $(@).parent().parent()
    
    if report_email?
      report_email.remove()
      $("#email_table_body").prepend("<tr height='59px;' class='" + report_email.attr("class") + "'>" +
                                     report_email.html() + "</tr>")

  prepareComposeModalWithEmailThreadData: (emailThread, subject_prefix="Re: ") ->
    if emailThread.reply_to_address?
      $("#compose_form #to_input").val(emailThread.reply_to_address)
    else
      $("#compose_form #to_input").val(emailThread.from_address)

    $("#compose_form #subject_input").val(subject_prefix + emailThread.subject)
    if emailThread.text_part?
      $("#compose_form #compose_email_body").val("\r\n\r\n\r\n\r\n" + emailThread.text_part)
    else
      $("#compose_form #compose_email_body").val("\r\n\r\n\r\n\r\n" + emailThread.body_text)

    $("#composeModal").modal "show"

  renderEmailPreview: ->
    TuringEmailApp.currentEmailThread = @collection.models[0]
    TuringEmailApp.previewEmailThreadView = new TuringEmailApp.Views.EmailThreads.EmailThreadView(
      model: TuringEmailApp.currentEmailThread
      el: $("#preview_content")
    )
    TuringEmailApp.previewEmailThreadView.render()
