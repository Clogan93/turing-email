TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.EmailThreadView extends Backbone.View
  template: JST["backbone/templates/email_threads/email_thread"]

  initialize: ->
    if @model
      @listenTo(@model, "change", @render)
      @listenTo(@model, "destroy", @remove)

  render: ->
    if @model
      modelJSON = @model.toJSON()
      modelJSON["fromPreview"] = @model.fromPreview()
      modelJSON["subjectPreview"] = @model.subjectPreview()
      modelJSON["datePreview"] = @model.datePreview()
      @$el.html(@template(modelJSON))
  
      @model.seenIs(true)
  
      @renderGenieReport()
      @renderHTMLEmails()
  
      @setupEmailExpandAndCollapse()
      @setupButtons()
    else
      @$el.empty()
    
    return this

  # TODO refactor
  # TODO write tests
  renderGenieReport: ->
    for email, index in @model.get("emails")
      if email.subject is "Turing Email - Your daily Genie Report!"
        @insertHtmlIntoIframe email, index
        iframe = @$el.find("#email_iframe" + index.toString())

        iframe.contents().find("body").find('a[href^="#email_thread"]').click (event) ->
          event.preventDefault()
          
          $('#composeModal').modal()
          subject = "Re: " + $(@).text()
          $('#composeModal #subject_input').val(subject)
          reply_link = $(@).parent().parent().find('a[href^="mailto:"]').attr("href").replace "mailto:", ""
          $('#composeModal #to_input').val(reply_link)

          thread_elements = $(@).attr("href").split("/")
          thread_id = thread_elements[thread_elements.length - 1]
          $.get "/api/v1/email_threads/show/" + thread_id, (data) ->
            email_from_email_thread = data.emails[data.emails.length - 1]
            $('#composeModal #compose_email_body').val("\n\n\n\n" + TuringEmailApp.views.composeView.retrieveEmailBodyAttributeToUseBasedOnAvailableAttributes(email_from_email_thread))
            $('#compose_form #email_in_reply_to_uid_input').val(email_from_email_thread.uid)

        iframe.contents().find("body").find('a[href^="#from_address"]').click (event) ->
          event.preventDefault()
          
          $("#email_filter_from").val($(@).attr("href").split("=")[1])
          $(window).scrollTop($('.navbar-header').position().top)
          $('.dropdown a').trigger('click.bs.dropdown')
          return false

        iframe.contents().find("body").find('a[href^="#list_id"]').click (event) ->
          event.preventDefault()
          
          $("#email_filter_list").val($(@).attr("href").split("=")[1])
          $(window).scrollTop($('.navbar-header').position().top)
          $('.dropdown a').trigger('click.bs.dropdown')
          return false

  # TODO write tests
  renderHTMLEmails: ->
    for email, index in @model.get("emails")
      if email.html_part?
        @insertHtmlIntoIframe email, index

  setupEmailExpandAndCollapse: ->
    @$el.find(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")

      $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

  setupButtons: ->
    if !TuringEmailApp.isSplitPaneMode()
      @$el.find("#email_back_button").click =>
        @trigger("goBackClicked", this)

    @$el.find(".email_reply_button").click =>
      @trigger("replyClicked", this)

    @$el.find(".email_forward_button").click =>
      @trigger("forwardClicked", this)

    @$el.find("i.fa-archive").parent().click =>
      @trigger("archiveClicked", this)

    @$el.find("i.fa-trash-o").parent().click =>
      @trigger("trashClicked", this)

  # TODO write tests
  insertHtmlIntoIframe: (email, index) ->
    iframe = @$el.find("#email_iframe" + index.toString())
    
    iframe.contents().find("html").html(email.html_part)
    email_height = iframe.contents().find("html").outerHeight(true)
    
    iframe.contents().find("html").css("overflow", "hidden")
    iframe.css("height", email_height.toString() + "px")
