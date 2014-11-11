class TuringEmailApp.Models.DelayedEmail extends TuringEmailApp.Models.Email
  idAttribute: "uid"
  
  @Delete: (delayedEmailUID) ->
    $.ajax
      url: "/api/v1/delayed_emails/" + delayedEmailUID
      type: "DELETE"
