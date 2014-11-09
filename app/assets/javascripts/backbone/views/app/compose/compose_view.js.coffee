TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.ComposeView extends Backbone.View
  template: JST["backbone/templates/app/compose/modal_compose"]

  initialize: (options) ->
    @app = options.app
  
  render: ->
    @$el.html(@template())
    @setupComposeView()
    @setupLinkPreviews()
    @setupEmoljis()
    return this

  setupComposeView: ->
    @$el.find(".summernote").summernote toolbar: [
      [
        "style"
        [
          "bold"
          "italic"
          "underline"
          "clear"
        ]
      ]
      [
        "fontname"
        ["fontname"]
      ]
      [
        "fontsize"
        ["fontsize"]
      ]
      [
        "color"
        ["color"]
      ]
      [
        "para"
        [
          "paragraph"
        ]
      ]
      [
        "height"
        ["height"]
      ]
    ]

    @$el.find(".compose-form").submit =>
      console.log "SEND clicked! Sending..."
      @sendEmail()
      return false

    @$el.find(".compose-form .save-button").click =>
      console.log "SAVE clicked - saving the draft!"
      
      # if already in the middle of saving, no reason to save again
      # it could be an error to save again if the draft_id isn't set because it would create duplicate drafts
      if @savingDraft
        console.log "SKIPPING SAVE - already saving!!"
        return

      @savingDraft = true

      @updateDraft()

      @currentEmailDraft.save(null,
        success: (model, response, options) =>
          console.log "SAVED! setting draft_id to " + response.draft_id
          model.set("draft_id", response.draft_id)
          @trigger "change:draft", this, model, @emailThreadParent

          @savingDraft = false
          
        error: (model, response, options) =>
          console.log "SAVE FAILED!!!"
          @savingDraft = false
      )

    @$el.find(".compose-modal").on "hidden.bs.modal", (event) =>
      @$el.find(".compose-form .save-button").click()

  show: ->
    @$el.find(".compose-modal").modal "show"
    
  hide: ->
    @$el.find(".compose-modal").modal "hide"

  showEmailSentAlert: (emailSentJSON) ->
    console.log "ComposeView showEmailSentAlert"
    
    @removeEmailSentAlert() if @currentAlertToken?
    
    @currentAlertToken = @app.showAlert('Your message has been sent. <span class="undo-email-send">Undo</span>', "alert-info")
    $(".undo-email-send").click =>
      clearTimeout(TuringEmailApp.sendEmailTimeout)
      
      @removeEmailSentAlert()
      @loadEmail(emailSentJSON)
      @show()
  
  removeEmailSentAlert: ->
    console.log "ComposeView REMOVE emailSentAlert"

    if @currentAlertToken?
      @app.removeAlert(@currentAlertToken)
      @currentAlertToken = null
    
  resetView: ->
    console.log("ComposeView RESET!!")
    
    @$el.find(".compose-form #email_sent_error_alert").remove()
    @removeEmailSentAlert()

    @currentEmailDraft = null
    @emailInReplyToUID = null
    @emailThreadParent = null

    @$el.find(".compose-form .to-input").val("")
    @$el.find(".compose-form .cc-input").val("")
    @$el.find(".compose-form .bcc-input").val("")

    @$el.find(".compose-form .subject-input").val("")
    @$el.find(".compose-form .note-editable").html("")

  loadEmpty: ->
    @resetView()

  loadEmail: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmail!!")
    @resetView()

    @loadEmailHeaders(emailJSON)
    @loadEmailBody(emailJSON)
    
    @emailThreadParent = emailThreadParent

  loadEmailDraft: (emailDraftJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailDraft!!")
    @resetView()
    
    @loadEmailHeaders(emailDraftJSON)
    @loadEmailBody(emailDraftJSON)

    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(emailDraftJSON)
    @emailThreadParent = emailThreadParent

  loadEmailAsReply: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsReply!!")
    @resetView()

    @$el.find(".compose-form .to-input").val(if emailJSON.reply_to_address? then emailJSON.reply_to_address else emailJSON.from_address)
    @$el.find(".compose-form .subject-input").val(@subjectWithPrefixFromEmail(emailJSON, "Re: "))
    @loadEmailBody(emailJSON, true)

    @emailInReplyToUID = emailJSON.uid
    @emailThreadParent = emailThreadParent

  loadEmailAsForward: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsForward!!")
    @resetView()

    @$el.find(".compose-form .subject-input").val(@subjectWithPrefixFromEmail(emailJSON, "Fwd: "))
    @loadEmailBody(emailJSON, true)
    
    @emailThreadParent = emailThreadParent

  loadEmailHeaders: (emailJSON) ->
    console.log("ComposeView loadEmailHeaders!!")
    @$el.find(".compose-form .to-input").val(emailJSON.tos)
    @$el.find(".compose-form .cc-input").val(emailJSON.ccs)
    @$el.find(".compose-form .bcc-input").val(emailJSON.bccs)

    @$el.find(".compose-form .subject-input").val(@subjectWithPrefixFromEmail(emailJSON))

  parseEmail: (emailJSON) ->
    htmlFailed = true
    
    if emailJSON.html_part?
      try
        emailHTML = $($.parseHTML(emailJSON.html_part))
        
        if emailHTML.length is 0 || not emailHTML[0].nodeName.match(/body/i)?
          body = $("<div />")
          body.html(emailHTML)
        else
          body = emailHTML

        htmlFailed = false
      catch error
        console.log error
        htmlFailed = true

    if htmlFailed
      bodyText = ""
      
      text = ""
      if emailJSON.text_part?
        text = emailJSON.text_part
      else if emailJSON.body_text?
        text = emailJSON.body_text
      
      for line in text.split("\n")
        bodyText += "> " + line + "\n"

      body = bodyText
    
    return [body, !htmlFailed]
    
  formatEmailReplyBody: (emailJSON) ->
    tDate = new TDate()
    tDate.initializeWithISO8601(emailJSON.date)

    headerText = "\r\n\r\n"
    headerText += tDate.longFormDateString() + ", " + emailJSON.from_address + " wrote:"
    headerText += "\r\n\r\n"

    headerText = headerText.replace(/\r\n/g, "<br />")

    [body, html] = @parseEmail(emailJSON)

    if html  
      $(body[0]).prepend(headerText)
    else
      body = body.replace(/\r\n/g, "<br />")
      body = $($.parseHTML(headerText + body))

    return body

  loadEmailBody: (emailJSON, isReply=false) ->
    console.log("ComposeView loadEmailBody!!")
    
    if isReply
      body = @formatEmailReplyBody(emailJSON) 
    else
      [body, html] = @parseEmail(emailJSON)
      body = $.parseHTML(body) if not html

    @$el.find(".compose-form .note-editable").html(body)
    
    return body

  subjectWithPrefixFromEmail: (emailJSON, subjectPrefix="") ->
    console.log("ComposeView subjectWithPrefixFromEmail")
    return subjectPrefix if not emailJSON.subject

    subjectWithoutForwardPrefix = emailJSON.subject.replace("Fwd: ", "")
    subjectWithoutForwardAndReplyPrefixes = subjectWithoutForwardPrefix.replace("Re: ", "")
    return subjectPrefix + subjectWithoutForwardAndReplyPrefixes

  updateDraft: ->
    console.log "ComposeView updateDraft!"
    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft() if not @currentEmailDraft?
    @updateEmail(@currentEmailDraft)

  updateEmail: (email) ->
    console.log "ComposeView updateEmail!"
    email.set("email_in_reply_to_uid", @emailInReplyToUID)

    email.set("tos", @$el.find(".compose-form").find(".to-input").val().split(","))
    email.set("ccs", @$el.find(".compose-form").find(".cc-input").val().split(","))
    email.set("bccs",  @$el.find(".compose-form").find(".bcc-input").val().split(","))

    email.set("subject", @$el.find(".compose-form").find(".subject-input").val())
    email.set("html_part", @$el.find(".compose-form").find(".note-editable").html())
    email.set("text_part", @$el.find(".compose-form").find(".note-editable").text())

  sendEmail: (draftToSend=null) ->
    console.log "ComposeView sendEmail!"
    
    if @currentEmailDraft? || draftToSend?
      console.log "sending DRAFT"
      
      if not draftToSend?
        console.log "NO draftToSend - not callback so update the draft and save it"
        # need to update and save the draft state because reset below clears it
        @updateDraft()
        draftToSend = @currentEmailDraft
        
        @resetView()
        @hide()
      
      if @savingDraft
        console.log "SAVING DRAFT!!!!!!! do TIMEOUT callback!"
        # if still saving the draft from save-button click need to retry because otherwise multiple drafts
        # might be created or the wrong version of the draft might be sent.
        setTimeout (=>
         @sendEmail(draftToSend)
        ), 500
      else
        console.log "NOT in middle of draft save - saving it then sending"
        
        draftToSend.save(null, {
          success: (model, response, options) =>
            console.log "SAVED! setting draft_id to " + response.draft_id
            draftToSend.set("draft_id", response.draft_id)
            @trigger "change:draft", this, model, @emailThreadParent
            
            @sendEmailDelayed(draftToSend)
        })
    else
      # easy case - no draft just send the email!
      console.log "NO draft! Sending"
      emailToSend = new TuringEmailApp.Models.Email()
      @updateEmail(emailToSend)
      @resetView()
      @hide()

      @sendEmailDelayed(emailToSend)
  
  sendEmailDelayed: (emailToSend) ->
    console.log "ComposeView sendEmailDelayed! - Setting up Undo button"
    @showEmailSentAlert(emailToSend.toJSON())

    TuringEmailApp.sendEmailTimeout = setTimeout (=>
      console.log "ComposeView sendEmailDelayed CALLBACK! doing send"
      @removeEmailSentAlert()

      if emailToSend instanceof TuringEmailApp.Models.EmailDraft
        console.log "sendDraft!"
        emailToSend.sendDraft(
          @app
          =>
            @trigger "change:draft", this, emailToSend, @emailThreadParent
          =>
            @sendEmailDelayedError(emailToSend.toJSON())
        )
      else
        console.log "send email!"
        emailToSend.sendEmail().done(=>
          @trigger "change:draft", this, emailToSend, @emailThreadParent
        ).fail(=>
          @sendEmailDelayedError(emailToSend.toJSON())
        )
    ), 5000

  sendEmailDelayedError: (emailToSendJSON) ->
    console.log "sendEmailDelayedError!!!"

    @loadEmail(emailToSendJSON, @emailThreadParent)
    @show()

    @$el.find(".compose-form").prepend('<div id="email_sent_error_alert" class="alert alert-danger" role="alert">
                                There was an error in sending your email!</div>')

  setupLinkPreviews: ->
    @$el.find(".compose-form .note-editable").bind "keydown", "space return shift+return", =>
      emailHtml = @$el.find(".compose-form .note-editable").html()
      indexOfUrl = emailHtml.search(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/)

      linkPreviewIndex = emailHtml.search("compose-link-preview")

      if indexOfUrl isnt -1 and linkPreviewIndex is -1
        link = emailHtml.substring(indexOfUrl)?.split(" ")?[0]

        websitePreview = new TuringEmailApp.Models.WebsitePreview(
          websiteURL: link
        )

        @websitePreviewView = new TuringEmailApp.Views.App.WebsitePreviewView(
          model: websitePreview
          el: @$el.find(".compose-form .note-editable")
        )
        websitePreview.fetch()

  setupEmoljis: ->
    console.log "setupEmoljis called"
    @$el.find(".note-toolbar.btn-toolbar").append('
    <div class="dropdown emolji-dropdown-div">
      <button class="btn btn-default dropdown-toggle" type="button" id="emoljiDropdownMenu" data-toggle="dropdown" style="padding-top: 5px; padding-bottom: 4px; margin-top: 5px; margin-left: 5px;">
        Emolji
        <span class="caret"></span>
      </button>
      <ul class="dropdown-menu emolji-dropdown" role="menu" aria-labelledby="emoljiDropdownMenu">
        <span>:+1:</span>
        <span>:-1:</span>
        <span>:100:</span>
        <span>:109:</span>
        <span>:1234:</span>
        <span>:8ball:</span>
        <span>:a:</span>
        <span>:ab:</span>
        <span>:abc:</span>
        <span>:abcd:</span>
        <span>:accept:</span>
        <span>:aerial_tramway:</span>
        <span>:airplane:</span>
        <span>:alarm_clock:</span>
        <span>:alien:</span>
        <span>:ambulance:</span>
        <span>:anchor:</span>
        <span>:angel:</span>
        <span>:anger:</span>
        <span>:angry:</span>
        <span>:anguished:</span>
        <span>:ant:</span>
        <span>:apple:</span>
        <span>:aquarius:</span>
        <span>:aries:</span>
        <span>:arrow_backward:</span>
        <span>:arrow_double_down:</span>
        <span>:arrow_double_up:</span>
        <span>:arrow_down:</span>
        <span>:arrow_down_small:</span>
        <span>:arrow_forward:</span>
        <span>:arrow_heading_down:</span>
        <span>:arrow_heading_up:</span>
        <span>:arrow_left:</span>
        <span>:arrow_lower_left:</span>
        <span>:arrow_lower_right:</span>
        <span>:arrow_right:</span>
        <span>:arrow_right_hook:</span>
        <span>:arrow_up:</span>
        <span>:arrow_up_down:</span>
        <span>:arrow_up_small:</span>
        <span>:arrow_upper_left:</span>
        <span>:arrow_upper_right:</span>
        <span>:arrows_clockwise:</span>
        <span>:arrows_counterclockwise:</span>
        <span>:art:</span>
        <span>:articulated_lorry:</span>
        <span>:astonished:</span>
        <span>:atm:</span>
        <span>:b:</span>
        <span>:baby:</span>
        <span>:baby_bottle:</span>
        <span>:baby_chick:</span>
        <span>:baby_symbol:</span>
        <span>:baggage_claim:</span>
        <span>:balloon:</span>
        <span>:ballot_box_with_check:</span>
        <span>:bamboo:</span>
        <span>:banana:</span>
        <span>:bangbang:</span>
        <span>:bank:</span>
        <span>:bar_chart:</span>
        <span>:barber:</span>
        <span>:baseball:</span>
        <span>:basketball:</span>
        <span>:bath:</span>
        <span>:bathtub:</span>
        <span>:battery:</span>
        <span>:bear:</span>
        <span>:bee:</span>
        <span>:beer:</span>
        <span>:beers:</span>
        <span>:beetle:</span>
        <span>:beginner:</span>
        <span>:bell:</span>
        <span>:bento:</span>
        <span>:bicyclist:</span>
        <span>:bike:</span>
        <span>:bikini:</span>
        <span>:bird:</span>
        <span>:birthday:</span>
        <span>:black_circle:</span>
        <span>:black_joker:</span>
        <span>:black_nib:</span>
        <span>:black_square:</span>
        <span>:black_square_button:</span>
        <span>:blossom:</span>
        <span>:blowfish:</span>
        <span>:blue_book:</span>
        <span>:blue_car:</span>
        <span>:blue_heart:</span>
        <span>:blush:</span>
        <span>:boar:</span>
        <span>:boat:</span>
        <span>:bomb:</span>
        <span>:book:</span>
        <span>:bookmark:</span>
        <span>:bookmark_tabs:</span>
        <span>:books:</span>
        <span>:boom:</span>
        <span>:boot:</span>
        <span>:bouquet:</span>
        <span>:bow:</span>
        <span>:bowling:</span>
        <span>:bowtie:</span>
        <span>:boy:</span>
        <span>:bread:</span>
        <span>:bride_with_veil:</span>
        <span>:bridge_at_night:</span>
        <span>:briefcase:</span>
        <span>:broken_heart:</span>
        <span>:bug:</span>
        <span>:bulb:</span>
        <span>:bullettrain_front:</span>
        <span>:bullettrain_side:</span>
        <span>:bus:</span>
        <span>:busstop:</span>
        <span>:bust_in_silhouette:</span>
        <span>:busts_in_silhouette:</span>
        <span>:cactus:</span>
        <span>:cake:</span>
        <span>:calendar:</span>
        <span>:calling:</span>
        <span>:camel:</span>
        <span>:camera:</span>
        <span>:cancer:</span>
        <span>:candy:</span>
        <span>:capital_abcd:</span>
        <span>:capricorn:</span>
        <span>:car:</span>
        <span>:card_index:</span>
        <span>:carousel_horse:</span>
        <span>:cat:</span>
        <span>:cat2:</span>
        <span>:cd:</span>
        <span>:chart:</span>
        <span>:chart_with_downwards_trend:</span>
        <span>:chart_with_upwards_trend:</span>
        <span>:checkered_flag:</span>
        <span>:cherries:</span>
        <span>:cherry_blossom:</span>
        <span>:chestnut:</span>
        <span>:chicken:</span>
        <span>:children_crossing:</span>
        <span>:chocolate_bar:</span>
        <span>:christmas_tree:</span>
        <span>:church:</span>
        <span>:cinema:</span>
        <span>:circus_tent:</span>
        <span>:city_sunrise:</span>
        <span>:city_sunset:</span>
        <span>:cl:</span>
        <span>:clap:</span>
        <span>:clapper:</span>
        <span>:clipboard:</span>
        <span>:clock1:</span>
        <span>:clock10:</span>
        <span>:clock1030:</span>
        <span>:clock11:</span>
        <span>:clock1130:</span>
        <span>:clock12:</span>
        <span>:clock1230:</span>
        <span>:clock130:</span>
        <span>:clock2:</span>
        <span>:clock230:</span>
        <span>:clock3:</span>
        <span>:clock330:</span>
        <span>:clock4:</span>
        <span>:clock430:</span>
        <span>:clock5:</span>
        <span>:clock530:</span>
        <span>:clock6:</span>
        <span>:clock630:</span>
        <span>:clock7:</span>
        <span>:clock730:</span>
        <span>:clock8:</span>
        <span>:clock830:</span>
        <span>:clock9:</span>
        <span>:clock930:</span>
        <span>:closed_book:</span>
        <span>:closed_lock_with_key:</span>
        <span>:closed_umbrella:</span>
        <span>:cloud:</span>
        <span>:clubs:</span>
        <span>:cn:</span>
        <span>:cocktail:</span>
        <span>:coffee:</span>
        <span>:cold_sweat:</span>
        <span>:collision:</span>
        <span>:computer:</span>
        <span>:confetti_ball:</span>
        <span>:confounded:</span>
        <span>:confused:</span>
        <span>:congratulations:</span>
        <span>:construction:</span>
        <span>:construction_worker:</span>
        <span>:convenience_store:</span>
        <span>:cookie:</span>
        <span>:cool:</span>
        <span>:cop:</span>
        <span>:copyright:</span>
        <span>:corn:</span>
        <span>:couple:</span>
        <span>:couple_with_heart:</span>
        <span>:couplekiss:</span>
        <span>:cow:</span>
        <span>:cow2:</span>
        <span>:credit_card:</span>
        <span>:crocodile:</span>
        <span>:crossed_flags:</span>
        <span>:crown:</span>
        <span>:cry:</span>
        <span>:crying_cat_face:</span>
        <span>:crystal_ball:</span>
        <span>:cupid:</span>
        <span>:curly_loop:</span>
        <span>:currency_exchange:</span>
        <span>:curry:</span>
        <span>:custard:</span>
        <span>:customs:</span>
        <span>:cyclone:</span>
        <span>:dancer:</span>
        <span>:dancers:</span>
        <span>:dango:</span>
        <span>:dart:</span>
        <span>:dash:</span>
        <span>:date:</span>
        <span>:de:</span>
        <span>:deciduous_tree:</span>
        <span>:department_store:</span>
        <span>:diamond_shape_with_a_dot_inside:</span>
        <span>:diamonds:</span>
        <span>:disappointed:</span>
        <span>:dizzy:</span>
        <span>:dizzy_face:</span>
        <span>:do_not_litter:</span>
        <span>:dog:</span>
        <span>:dog2:</span>
        <span>:dollar:</span>
        <span>:dolls:</span>
        <span>:dolphin:</span>
        <span>:door:</span>
        <span>:doughnut:</span>
        <span>:dragon:</span>
        <span>:dragon_face:</span>
        <span>:dress:</span>
        <span>:dromedary_camel:</span>
        <span>:droplet:</span>
        <span>:dvd:</span>
        <span>:e-mail:</span>
        <span>:ear:</span>
        <span>:ear_of_rice:</span>
        <span>:earth_africa:</span>
        <span>:earth_americas:</span>
        <span>:earth_asia:</span>
        <span>:egg:</span>
        <span>:eggplant:</span>
        <span>:eight:</span>
        <span>:eight_pointed_black_star:</span>
        <span>:eight_spoked_asterisk:</span>
        <span>:electric_plug:</span>
        <span>:elephant:</span>
        <span>:email:</span>
        <span>:end:</span>
        <span>:envelope:</span>
        <span>:es:</span>
        <span>:euro:</span>
        <span>:european_castle:</span>
        <span>:european_post_office:</span>
        <span>:evergreen_tree:</span>
        <span>:exclamation:</span>
        <span>:expressionless:</span>
        <span>:eyeglasses:</span>
        <span>:eyes:</span>
        <span>:facepunch:</span>
        <span>:factory:</span>
        <span>:fallen_leaf:</span>
        <span>:family:</span>
        <span>:fast_forward:</span>
        <span>:fax:</span>
        <span>:fearful:</span>
        <span>:feelsgood:</span>
        <span>:feet:</span>
        <span>:ferris_wheel:</span>
        <span>:file_folder:</span>
        <span>:finnadie:</span>
        <span>:fire:</span>
        <span>:fire_engine:</span>
        <span>:fireworks:</span>
        <span>:first_quarter_moon:</span>
        <span>:first_quarter_moon_with_face:</span>
        <span>:fish:</span>
        <span>:fish_cake:</span>
        <span>:fishing_pole_and_fish:</span>
        <span>:fist:</span>
        <span>:five:</span>
        <span>:flags:</span>
        <span>:flashlight:</span>
        <span>:floppy_disk:</span>
        <span>:flower_playing_cards:</span>
        <span>:flushed:</span>
        <span>:foggy:</span>
        <span>:football:</span>
        <span>:fork_and_knife:</span>
        <span>:fountain:</span>
        <span>:four:</span>
        <span>:four_leaf_clover:</span>
        <span>:fr:</span>
        <span>:free:</span>
        <span>:fried_shrimp:</span>
        <span>:fries:</span>
        <span>:frog:</span>
        <span>:frowning:</span>
        <span>:fuelpump:</span>
        <span>:full_moon:</span>
        <span>:full_moon_with_face:</span>
        <span>:game_die:</span>
        <span>:gb:</span>
        <span>:gem:</span>
        <span>:gemini:</span>
        <span>:ghost:</span>
        <span>:gift:</span>
        <span>:gift_heart:</span>
        <span>:girl:</span>
        <span>:globe_with_meridians:</span>
        <span>:goat:</span>
        <span>:goberserk:</span>
        <span>:godmode:</span>
        <span>:golf:</span>
        <span>:grapes:</span>
        <span>:green_apple:</span>
        <span>:green_book:</span>
        <span>:green_heart:</span>
        <span>:grey_exclamation:</span>
        <span>:grey_question:</span>
        <span>:grimacing:</span>
        <span>:grin:</span>
        <span>:grinning:</span>
        <span>:guardsman:</span>
        <span>:guitar:</span>
        <span>:gun:</span>
        <span>:haircut:</span>
        <span>:hamburger:</span>
        <span>:hammer:</span>
        <span>:hamster:</span>
        <span>:hand:</span>
        <span>:handbag:</span>
        <span>:hankey:</span>
        <span>:hash:</span>
        <span>:hatched_chick:</span>
        <span>:hatching_chick:</span>
        <span>:headphones:</span>
        <span>:hear_no_evil:</span>
        <span>:heart:</span>
        <span>:heart_decoration:</span>
        <span>:heart_eyes:</span>
        <span>:heart_eyes_cat:</span>
        <span>:heartbeat:</span>
        <span>:heartpulse:</span>
        <span>:hearts:</span>
        <span>:heavy_check_mark:</span>
        <span>:heavy_division_sign:</span>
        <span>:heavy_dollar_sign:</span>
        <span>:heavy_exclamation_mark:</span>
        <span>:heavy_minus_sign:</span>
        <span>:heavy_multiplication_x:</span>
        <span>:heavy_plus_sign:</span>
        <span>:helicopter:</span>
        <span>:herb:</span>
        <span>:hibiscus:</span>
        <span>:high_brightness:</span>
        <span>:high_heel:</span>
        <span>:hocho:</span>
        <span>:honey_pot:</span>
        <span>:honeybee:</span>
        <span>:horse:</span>
        <span>:horse_racing:</span>
        <span>:hospital:</span>
        <span>:hotel:</span>
        <span>:hotsprings:</span>
        <span>:hourglass:</span>
        <span>:hourglass_flowing_sand:</span>
        <span>:house:</span>
        <span>:house_with_garden:</span>
        <span>:hurtrealbad:</span>
        <span>:hushed:</span>
        <span>:ice_cream:</span>
        <span>:icecream:</span>
        <span>:id:</span>
        <span>:ideograph_advantage:</span>
        <span>:imp:</span>
        <span>:inbox_tray:</span>
        <span>:incoming_envelope:</span>
        <span>:information_desk_person:</span>
        <span>:information_source:</span>
        <span>:innocent:</span>
        <span>:interrobang:</span>
        <span>:iphone:</span>
        <span>:it:</span>
        <span>:izakaya_lantern:</span>
        <span>:jack_o_lantern:</span>
        <span>:japan:</span>
        <span>:japanese_castle:</span>
        <span>:japanese_goblin:</span>
        <span>:japanese_ogre:</span>
        <span>:jeans:</span>
        <span>:joy:</span>
        <span>:joy_cat:</span>
        <span>:jp:</span>
        <span>:key:</span>
        <span>:keycap_ten:</span>
        <span>:kimono:</span>
        <span>:kiss:</span>
        <span>:kissing:</span>
        <span>:kissing_cat:</span>
        <span>:kissing_closed_eyes:</span>
        <span>:kissing_face:</span>
        <span>:kissing_heart:</span>
        <span>:kissing_smiling_eyes:</span>
        <span>:koala:</span>
        <span>:koko:</span>
        <span>:kr:</span>
        <span>:large_blue_circle:</span>
        <span>:large_blue_diamond:</span>
        <span>:large_orange_diamond:</span>
        <span>:last_quarter_moon:</span>
        <span>:last_quarter_moon_with_face:</span>
        <span>:laughing:</span>
        <span>:leaves:</span>
        <span>:ledger:</span>
        <span>:left_luggage:</span>
        <span>:left_right_arrow:</span>
        <span>:leftwards_arrow_with_hook:</span>
        <span>:lemon:</span>
        <span>:leo:</span>
        <span>:leopard:</span>
        <span>:libra:</span>
        <span>:light_rail:</span>
        <span>:link:</span>
        <span>:lips:</span>
        <span>:lipstick:</span>
        <span>:lock:</span>
        <span>:lock_with_ink_pen:</span>
        <span>:lollipop:</span>
        <span>:loop:</span>
        <span>:loudspeaker:</span>
        <span>:love_hotel:</span>
        <span>:love_letter:</span>
        <span>:low_brightness:</span>
        <span>:m:</span>
        <span>:mag:</span>
        <span>:mag_right:</span>
        <span>:mahjong:</span>
        <span>:mailbox:</span>
        <span>:mailbox_closed:</span>
        <span>:mailbox_with_mail:</span>
        <span>:mailbox_with_no_mail:</span>
        <span>:man:</span>
        <span>:man_with_gua_pi_mao:</span>
        <span>:man_with_turban:</span>
        <span>:mans_shoe:</span>
        <span>:maple_leaf:</span>
        <span>:mask:</span>
        <span>:massage:</span>
        <span>:meat_on_bone:</span>
        <span>:mega:</span>
        <span>:melon:</span>
        <span>:memo:</span>
        <span>:mens:</span>
        <span>:metal:</span>
        <span>:metro:</span>
        <span>:microphone:</span>
        <span>:microscope:</span>
        <span>:milky_way:</span>
        <span>:minibus:</span>
        <span>:minidisc:</span>
        <span>:mobile_phone_off:</span>
        <span>:money_with_wings:</span>
        <span>:moneybag:</span>
        <span>:monkey:</span>
        <span>:monkey_face:</span>
        <span>:monorail:</span>
        <span>:moon:</span>
        <span>:mortar_board:</span>
        <span>:mount_fuji:</span>
        <span>:mountain_bicyclist:</span>
        <span>:mountain_cableway:</span>
        <span>:mountain_railway:</span>
        <span>:mouse:</span>
        <span>:mouse2:</span>
        <span>:movie_camera:</span>
        <span>:moyai:</span>
        <span>:muscle:</span>
        <span>:mushroom:</span>
        <span>:musical_keyboard:</span>
        <span>:musical_note:</span>
        <span>:musical_score:</span>
        <span>:mute:</span>
        <span>:nail_care:</span>
        <span>:name_badge:</span>
        <span>:neckbeard:</span>
        <span>:necktie:</span>
        <span>:negative_squared_cross_mark:</span>
        <span>:neutral_face:</span>
        <span>:new:</span>
        <span>:new_moon:</span>
        <span>:new_moon_with_face:</span>
        <span>:newspaper:</span>
        <span>:ng:</span>
        <span>:nine:</span>
        <span>:no_bell:</span>
        <span>:no_bicycles:</span>
        <span>:no_entry:</span>
        <span>:no_entry_sign:</span>
        <span>:no_good:</span>
        <span>:no_mobile_phones:</span>
        <span>:no_mouth:</span>
        <span>:no_pedestrians:</span>
        <span>:no_smoking:</span>
        <span>:non-potable_water:</span>
        <span>:nose:</span>
        <span>:notebook:</span>
        <span>:notebook_with_decorative_cover:</span>
        <span>:notes:</span>
        <span>:nut_and_bolt:</span>
        <span>:o:</span>
        <span>:o2:</span>
        <span>:ocean:</span>
        <span>:octocat:</span>
        <span>:octopus:</span>
        <span>:oden:</span>
        <span>:office:</span>
        <span>:ok:</span>
        <span>:ok_hand:</span>
        <span>:ok_woman:</span>
        <span>:older_man:</span>
        <span>:older_woman:</span>
        <span>:on:</span>
        <span>:oncoming_automobile:</span>
        <span>:oncoming_bus:</span>
        <span>:oncoming_police_car:</span>
        <span>:oncoming_taxi:</span>
        <span>:one:</span>
        <span>:open_file_folder:</span>
        <span>:open_hands:</span>
        <span>:open_mouth:</span>
        <span>:ophiuchus:</span>
        <span>:orange_book:</span>
        <span>:outbox_tray:</span>
        <span>:ox:</span>
        <span>:page_facing_up:</span>
        <span>:page_with_curl:</span>
        <span>:pager:</span>
        <span>:palm_tree:</span>
        <span>:panda_face:</span>
        <span>:paperclip:</span>
        <span>:parking:</span>
        <span>:part_alternation_mark:</span>
        <span>:partly_sunny:</span>
        <span>:passport_control:</span>
        <span>:paw_prints:</span>
        <span>:peach:</span>
        <span>:pear:</span>
        <span>:pencil:</span>
        <span>:pencil2:</span>
        <span>:penguin:</span>
        <span>:pensive:</span>
        <span>:performing_arts:</span>
        <span>:persevere:</span>
        <span>:person_frowning:</span>
        <span>:person_with_blond_hair:</span>
        <span>:person_with_pouting_face:</span>
        <span>:phone:</span>
        <span>:pig:</span>
        <span>:pig2:</span>
        <span>:pig_nose:</span>
        <span>:pill:</span>
        <span>:pineapple:</span>
        <span>:pisces:</span>
        <span>:pizza:</span>
        <span>:plus1:</span>
        <span>:point_down:</span>
        <span>:point_left:</span>
        <span>:point_right:</span>
        <span>:point_up:</span>
        <span>:point_up_2:</span>
        <span>:police_car:</span>
        <span>:poodle:</span>
        <span>:poop:</span>
        <span>:post_office:</span>
        <span>:postal_horn:</span>
        <span>:postbox:</span>
        <span>:potable_water:</span>
        <span>:pouch:</span>
        <span>:poultry_leg:</span>
        <span>:pound:</span>
        <span>:pouting_cat:</span>
        <span>:pray:</span>
        <span>:princess:</span>
        <span>:punch:</span>
        <span>:purple_heart:</span>
        <span>:purse:</span>
        <span>:pushpin:</span>
        <span>:put_litter_in_its_place:</span>
        <span>:question:</span>
        <span>:rabbit:</span>
        <span>:rabbit2:</span>
        <span>:racehorse:</span>
        <span>:radio:</span>
        <span>:radio_button:</span>
        <span>:rage:</span>
        <span>:rage1:</span>
        <span>:rage2:</span>
        <span>:rage3:</span>
        <span>:rage4:</span>
        <span>:railway_car:</span>
        <span>:rainbow:</span>
        <span>:raised_hand:</span>
        <span>:raised_hands:</span>
        <span>:ram:</span>
        <span>:ramen:</span>
        <span>:rat:</span>
        <span>:recycle:</span>
        <span>:red_car:</span>
        <span>:red_circle:</span>
        <span>:registered:</span>
        <span>:relaxed:</span>
        <span>:relieved:</span>
        <span>:repeat:</span>
        <span>:repeat_one:</span>
        <span>:restroom:</span>
        <span>:revolving_hearts:</span>
        <span>:rewind:</span>
        <span>:ribbon:</span>
        <span>:rice:</span>
        <span>:rice_ball:</span>
        <span>:rice_cracker:</span>
        <span>:rice_scene:</span>
        <span>:ring:</span>
        <span>:rocket:</span>
        <span>:roller_coaster:</span>
        <span>:rooster:</span>
        <span>:rose:</span>
        <span>:rotating_light:</span>
        <span>:round_pushpin:</span>
        <span>:rowboat:</span>
        <span>:ru:</span>
        <span>:rugby_football:</span>
        <span>:runner:</span>
        <span>:running:</span>
        <span>:running_shirt_with_sash:</span>
        <span>:sa:</span>
        <span>:sagittarius:</span>
        <span>:sailboat:</span>
        <span>:sake:</span>
        <span>:sandal:</span>
        <span>:santa:</span>
        <span>:satellite:</span>
        <span>:satisfied:</span>
        <span>:saxophone:</span>
        <span>:school:</span>
        <span>:school_satchel:</span>
        <span>:scissors:</span>
        <span>:scorpius:</span>
        <span>:scream:</span>
        <span>:scream_cat:</span>
        <span>:scroll:</span>
        <span>:seat:</span>
        <span>:secret:</span>
        <span>:see_no_evil:</span>
        <span>:seedling:</span>
        <span>:seven:</span>
        <span>:shaved_ice:</span>
        <span>:sheep:</span>
        <span>:shell:</span>
        <span>:ship:</span>
        <span>:shipit:</span>
        <span>:shirt:</span>
        <span>:shit:</span>
        <span>:shoe:</span>
        <span>:shower:</span>
        <span>:signal_strength:</span>
        <span>:six:</span>
        <span>:six_pointed_star:</span>
        <span>:ski:</span>
        <span>:skull:</span>
        <span>:sleeping:</span>
        <span>:sleepy:</span>
        <span>:slot_machine:</span>
        <span>:small_blue_diamond:</span>
        <span>:small_orange_diamond:</span>
        <span>:small_red_triangle:</span>
        <span>:small_red_triangle_down:</span>
        <span>:smile:</span>
        <span>:smile_cat:</span>
        <span>:smiley:</span>
        <span>:smiley_cat:</span>
        <span>:smiling_imp:</span>
        <span>:smirk:</span>
        <span>:smirk_cat:</span>
        <span>:smoking:</span>
        <span>:snail:</span>
        <span>:snake:</span>
        <span>:snowboarder:</span>
        <span>:snowflake:</span>
        <span>:snowman:</span>
        <span>:sob:</span>
        <span>:soccer:</span>
        <span>:soon:</span>
        <span>:sos:</span>
        <span>:sound:</span>
        <span>:space_invader:</span>
        <span>:spades:</span>
        <span>:spaghetti:</span>
        <span>:sparkler:</span>
        <span>:sparkles:</span>
        <span>:sparkling_heart:</span>
        <span>:speak_no_evil:</span>
        <span>:speaker:</span>
        <span>:speech_balloon:</span>
        <span>:speedboat:</span>
        <span>:squirrel:</span>
        <span>:star:</span>
        <span>:star2:</span>
        <span>:stars:</span>
        <span>:station:</span>
        <span>:statue_of_liberty:</span>
        <span>:steam_locomotive:</span>
        <span>:stew:</span>
        <span>:straight_ruler:</span>
        <span>:strawberry:</span>
        <span>:stuck_out_tongue:</span>
        <span>:stuck_out_tongue_closed_eyes:</span>
        <span>:stuck_out_tongue_winking_eye:</span>
        <span>:sun_with_face:</span>
        <span>:sunflower:</span>
        <span>:sunglasses:</span>
        <span>:sunny:</span>
        <span>:sunrise:</span>
        <span>:sunrise_over_mountains:</span>
        <span>:surfer:</span>
        <span>:sushi:</span>
        <span>:suspect:</span>
        <span>:suspension_railway:</span>
        <span>:sweat:</span>
        <span>:sweat_drops:</span>
        <span>:sweat_smile:</span>
        <span>:sweet_potato:</span>
        <span>:swimmer:</span>
        <span>:symbols:</span>
        <span>:syringe:</span>
        <span>:tada:</span>
        <span>:tanabata_tree:</span>
        <span>:tangerine:</span>
        <span>:taurus:</span>
        <span>:taxi:</span>
        <span>:tea:</span>
        <span>:telephone:</span>
        <span>:telephone_receiver:</span>
        <span>:telescope:</span>
        <span>:tennis:</span>
        <span>:tent:</span>
        <span>:thought_balloon:</span>
        <span>:three:</span>
        <span>:thumbsdown:</span>
        <span>:thumbsup:</span>
        <span>:ticket:</span>
        <span>:tiger:</span>
        <span>:tiger2:</span>
        <span>:tired_face:</span>
        <span>:tm:</span>
        <span>:toilet:</span>
        <span>:tokyo_tower:</span>
        <span>:tomato:</span>
        <span>:tongue:</span>
        <span>:top:</span>
        <span>:tophat:</span>
        <span>:tractor:</span>
        <span>:traffic_light:</span>
        <span>:train:</span>
        <span>:train2:</span>
        <span>:tram:</span>
        <span>:triangular_flag_on_post:</span>
        <span>:triangular_ruler:</span>
        <span>:trident:</span>
        <span>:triumph:</span>
        <span>:trolleybus:</span>
        <span>:trollface:</span>
        <span>:trophy:</span>
        <span>:tropical_drink:</span>
        <span>:tropical_fish:</span>
        <span>:truck:</span>
        <span>:trumpet:</span>
        <span>:tshirt:</span>
        <span>:tulip:</span>
        <span>:turtle:</span>
        <span>:tv:</span>
        <span>:twisted_rightwards_arrows:</span>
        <span>:two:</span>
        <span>:two_hearts:</span>
        <span>:two_men_holding_hands:</span>
        <span>:two_women_holding_hands:</span>
        <span>:u5272:</span>
        <span>:u5408:</span>
        <span>:u55b6:</span>
        <span>:u6307:</span>
        <span>:u6708:</span>
        <span>:u6709:</span>
        <span>:u6e80:</span>
        <span>:u7121:</span>
        <span>:u7533:</span>
        <span>:u7981:</span>
        <span>:u7a7a:</span>
        <span>:uk:</span>
        <span>:umbrella:</span>
        <span>:unamused:</span>
        <span>:underage:</span>
        <span>:unlock:</span>
        <span>:up:</span>
        <span>:us:</span>
        <span>:v:</span>
        <span>:vertical_traffic_light:</span>
        <span>:vhs:</span>
        <span>:vibration_mode:</span>
        <span>:video_camera:</span>
        <span>:video_game:</span>
        <span>:violin:</span>
        <span>:virgo:</span>
        <span>:volcano:</span>
        <span>:vs:</span>
        <span>:walking:</span>
        <span>:waning_crescent_moon:</span>
        <span>:waning_gibbous_moon:</span>
        <span>:warning:</span>
        <span>:watch:</span>
        <span>:water_buffalo:</span>
        <span>:watermelon:</span>
        <span>:wave:</span>
        <span>:wavy_dash:</span>
        <span>:waxing_crescent_moon:</span>
        <span>:waxing_gibbous_moon:</span>
        <span>:wc:</span>
        <span>:weary:</span>
        <span>:wedding:</span>
        <span>:whale:</span>
        <span>:whale2:</span>
        <span>:wheelchair:</span>
        <span>:white_check_mark:</span>
        <span>:white_circle:</span>
        <span>:white_flower:</span>
        <span>:white_square:</span>
        <span>:white_square_button:</span>
        <span>:wind_chime:</span>
        <span>:wine_glass:</span>
        <span>:wink:</span>
        <span>:wink2:</span>
        <span>:wolf:</span>
        <span>:woman:</span>
        <span>:womans_clothes:</span>
        <span>:womans_hat:</span>
        <span>:womens:</span>
        <span>:worried:</span>
        <span>:wrench:</span>
        <span>:x:</span>
        <span>:yellow_heart:</span>
        <span>:yen:</span>
        <span>:yum:</span>
        <span>:zap:</span>
        <span>:zero:</span>
        <span>:zzz:</span>
      </ul>
    </div>')

    @$el.find(".emolji-dropdown").emoji()

    noteEditable = @$el.find(".compose-form .note-editable")
    @$el.find(".emolji-dropdown span").click ->
      noteEditable.append($(@).html())
