TuringEmailApp.Models.InstalledApps ||= {}

class TuringEmailApp.Models.InstalledApps.InstalledPanelApp extends TuringEmailApp.Models.InstalledApps.InstalledApp
  @GetEmailThreadAppJSON: (emailThread) ->
    emailThreadAppJSON = emailThread.toJSON()
    for email in emailThreadAppJSON.emails
      delete email["body_text_encoded"]
      delete email["html_part_encoded"]
      delete email["text_part_encoded"]
      
    return emailThreadAppJSON
    
  run: (iframe, emailThread) ->
    emailThread.load(
      success: =>
        emailThreadAppJSON = TuringEmailApp.Models.InstalledApps.InstalledPanelApp.GetEmailThreadAppJSON(emailThread)
        
        $.post(@get("app").callback_url, {
          email_thread: emailThreadAppJSON
        }, null, "html").done(
          (data, status) ->
            iframe.contents().find("html").html(data)
        )
    )
