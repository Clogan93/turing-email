TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.EmailThreadView extends Backbone.View
  template: JST["backbone/templates/email_threads/email_thread"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  remove: ->
    @$el.remove()

  render: ->
    @$el.html(@template(@model.toJSON()))

    @model.seenIs(true)

    @renderGenieReport()
    @renderHtmlPartsOfEmails()

    @setupEmailExpandAndCollapse()
    @setupReplyButtons()
    @setupForwardButton()

    return

  setupReplyButtons: ->
    $(".email_reply_button").click =>
      last_email_in_thread = TuringEmailApp.currentEmailThread.get("emails")[0]
      TuringEmailApp.emailThreadsListView.prepareComposeModalWithEmailThreadData last_email_in_thread
      $("#compose_form #email_in_reply_to_uid_input").val(last_email_in_thread.uid)

  setupForwardButton: ->
    $(".email_forward_button").click ->
      last_email_in_thread = TuringEmailApp.currentEmailThread.get("emails")[0]

      $("#compose_form #subject_input").val("Fwd: " + last_email_in_thread.subject)
      $("#compose_form #compose_email_body").val("\n\n\n\n\n" + last_email_in_thread.body_text)

      $("#composeModal").modal "show"

  insertHtmlIntoIframe: (email, index) ->
    @$el.find("#email_iframe" + index.toString()).contents().find("body").append(email.html_part)
    body_height_sum = 0
    
    @$el.find("#email_iframe" + index.toString()).contents().find("body").children().each ->
      body_height = $(@).height()
      body_height_sum += body_height
    
    body_height_adjusted = body_height_sum + 25
    body_height_adjusted_string = body_height_adjusted.toString() + "px"
    
    @$el.find("#email_iframe" + index.toString()).css("height", body_height_adjusted_string)

  renderHtmlPartsOfEmails: ->
    for email, index in @model.get("emails")
      if email.html_part?
        @insertHtmlIntoIframe email, index

  renderGenieReport: ->
    for email, index in @model.get("emails")
      if email.subject is "Turing Email - Your daily Genie Report!"
        @insertHtmlIntoIframe email, index

        @$el.find("#email_iframe" + index.toString()).contents().find("body").find('a[href^="#email_thread"]').click (event) ->
          event.preventDefault()
          $('#composeModal').modal()
          subject = "Re: " + $(@).text()
          $('#composeModal #subject_input').val(subject)
          reply_link = $(@).parent().parent().find('a[href^="mailto:"]').attr("href").replace "mailto:", ""
          $('#composeModal #to_input').val(reply_link)

          thread_elements = $(@).attr("href").split("#")
          thread_id = thread_elements[thread_elements.length - 1]
          $.get "/api/v1/email_threads/show/" + thread_id, (data) ->
            $('#composeModal #compose_email_body').val("\n\n\n\n" + data.emails[data.emails.length - 1].text_part)

        @$el.find("#email_iframe" + index.toString()).contents().find("body").find('a[href^="#from_address"]').click (event) ->
          event.preventDefault()
          $("#email_filter_from").val($(@).attr("href").split("=")[1])
          $(window).scrollTop($('.navbar-header').position().top)
          $('.dropdown a').trigger('click.bs.dropdown')
          return false

        @$el.find("#email_iframe" + index.toString()).contents().find("body").find('a[href^="#list_id"]').click (event) ->
          event.preventDefault()
          $("#email_filter_list").val($(@).attr("href").split("=")[1])
          $(window).scrollTop($('.navbar-header').position().top)
          $('.dropdown a').trigger('click.bs.dropdown')
          return false

  setupEmailExpandAndCollapse: ->
    @$el.find(".email").click ->

      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")

      $(this).siblings(".email").each ->

        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()
