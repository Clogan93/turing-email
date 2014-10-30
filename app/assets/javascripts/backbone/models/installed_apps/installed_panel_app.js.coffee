TuringEmailApp.Models.InstalledApps ||= {}

class TuringEmailApp.Models.InstalledApps.InstalledPanelApp extends TuringEmailApp.Models.InstalledApps.InstalledApp
  
  run: (iframe, emailThread) ->
    $.post(@get("app").callback_url, {
      email_thread: emailThread.toJSON()
    }, null, "html").done(
      (data, status) ->
        iframe.contents().find("html").html(data)
    )
