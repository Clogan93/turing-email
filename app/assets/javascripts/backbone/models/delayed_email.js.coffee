class TuringEmailApp.Models.DelayedEmail extends Backbone.Model
  idAttribute: "uid"
  
  @Delete: (delayedEmailUID) ->
    $.ajax
      url: "/api/v1/delayed_emails/" + delayedEmailUID
      type: "DELETE"
