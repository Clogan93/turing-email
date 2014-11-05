TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.EmailThreadView extends Backbone.View
  template: JST["backbone/templates/email_threads/email_thread"]

  initialize: ->
    if @model
      @listenTo(@model, "change", @render)
      @listenTo(@model, "destroy", @remove)

  render: ->
    return if @rendering
    
    if @model
      @seenChanging = @model._changing && @model.changed.seen?
      @rendering = true
      
      @model.load(
        success: =>
          @model.set("seen", true) if not @seenChanging

          modelJSON = @model.toJSON()
          modelJSON["sortedEmails"] = @model.sortedEmails()
          
          @addPreviewDataToTheModelJSON(modelJSON)
          
          @$el.html(@template(modelJSON))
          @$el.addClass("email-thread")

          @renderDrafts()
          @renderGenieReport()
          @renderHTMLEmails()
  
          @setupEmailExpandAndCollapse()
          @setupButtons()
          @setupTooltips()

          @rendering = false

        error: =>
          @rendering = false
      )
    else
      @$el.empty()

    return this

  addPreviewDataToTheModelJSON: (modelJSON) ->
    modelJSON["fromPreview"] = @model.fromPreview()
    modelJSON["subjectPreview"] = @model.subjectPreview()
    modelJSON["datePreview"] = @model.datePreview()
    
    for email in modelJSON.emails
      email["datePreview"] = TuringEmailApp.Models.Email.localDateString(email["date"])
      if email.from_name?
        email["fromPreview"] = email.from_name
      else
        email["fromPreview"] = email.from_address

  # TODO refactor
  # TODO write tests
  renderGenieReport: ->
    for email, index in @model.get("emails")
      if email.subject is "Turing Email - Your daily Brain Report!"
        @insertHtmlIntoIframe email, index
        iframe = @$el.find("#email_iframe" + index.toString())

        iframe.contents().find("body").find('a[href^="#email_thread"]').click (event) ->
          event.preventDefault()
          
          $('.compose-modal').modal()
          subject = "Re: " + $(@).text()
          $('.compose-modal .subject-input').val(subject)
          reply_link = $(@).parent().parent().find('a[href^="mailto:"]').attr("href").replace "mailto:", ""
          $('.compose-modal .to-input').val(reply_link)

          thread_elements = $(@).attr("href").split("/")
          thread_id = thread_elements[thread_elements.length - 1]
          $.get "/api/v1/email_threads/show/" + thread_id, (data) ->
            email_from_email_thread = data.emails[data.emails.length - 1]
            $('.compose-modal .compose-email-body').val("\n\n\n\n" + TuringEmailApp.Views.App.ComposeView.retrieveEmailBodyAttributeToUseBasedOnAvailableAttributes(email_from_email_thread))
            $('#compose-form #email_in_reply_to_uid_input').val(email_from_email_thread.uid)

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

    @updateIframeHeight(@$el.find("iframe").last())

  renderDrafts: ->
    @embeddedComposeViews = {}

    for email in @model.get("emails")
      if email.draft_id?
        embeddedComposeView = @embeddedComposeViews[email.uid] = new TuringEmailApp.Views.App.EmbeddedComposeView(app: TuringEmailApp)
        embeddedComposeView.email = email
        embeddedComposeView.emailThread = @model
        embeddedComposeView.render()
        @$el.find(".embedded_compose_view_" + email.uid).append(embeddedComposeView.$el)

  setupEmailExpandAndCollapse: ->
    @$el.find(".email .email-information").click (event) =>
      $(event.currentTarget).parent().find(".email-body").toggle()
      $(event.currentTarget).parent().toggleClass("collapsed-email")
      $(event.currentTarget).toggleClass("email-date-displayed")

      iframe = $(event.currentTarget).parent().find("iframe")
      @updateIframeHeight(iframe)

      $(event.currentTarget).parent().siblings(".email").each ->
        $(this).addClass "collapsed-email"
        $(this).find(".email-body").hide()

  setupButtons: ->
    if !TuringEmailApp.isSplitPaneMode()
      @$el.find(".email-back-button").click =>
        @trigger("goBackClicked", this)

    @$el.find(".email_reply_button").click =>
      @trigger("replyClicked", this)

    @$el.find(".email_forward_button").click =>
      @trigger("forwardClicked", this)

  setupTooltips: ->
    @$el.find(".email-to").tooltip()

  # TODO write tests
  insertHtmlIntoIframe: (email, index) ->
    iframe = @$el.find("#email_iframe" + index.toString())

    iframeHTML = iframe.contents().find("html")
    iframeHTML.html("<div>" + email.html_part + "</div>")

    body = iframe.contents().find("body")
    
    iframeHTML.css("overflow", "hidden")
    body.css("margin", "0px")

    iframe.contents().find("img").load(=>
      @updateIframeHeight(iframe)
    )

  updateIframeHeight: (iframe) ->
    body = iframe.contents().find("body")

    if body.length > 0
      div = $(body.children()[0])
      iframe.height(div.outerHeight(true))
      body.height(div.outerHeight(true))
    else
      html = iframe.contents().find("html")
      iframe.height(html.outerHeight(true))
