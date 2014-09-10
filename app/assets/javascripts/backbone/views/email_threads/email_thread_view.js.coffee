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
    console.log "render_genie_report"
    for email, index in @model.get("emails")
      console.log "render_genie_report loop"
      if email.subject is "Turing Email - Your daily Genie Report!"
        console.log "render_genie_report conditional"
        @$el.find("#email_iframe" + index.toString()).contents().find("body").append(email.html_part);
        body_height = @$el.find("#email_iframe" + index.toString()).contents().find("body").css("height")
        body_height_adjusted = parseInt(body_height.replace("px","")) + 25
        body_height_adjusted_string = body_height_adjusted.toString() + "px"
        @$el.find("#email_iframe" + index.toString()).css("height", body_height_adjusted_string)

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

  bindEmailClick: ->
    @$el.find(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")

      $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

  setSeen: ->
    @model.setSeen()
