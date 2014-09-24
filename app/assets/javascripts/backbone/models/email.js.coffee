class TuringEmailApp.Models.Email extends Backbone.Model
  sendEmail: ->
    $.ajax({
      url: "/api/v1/email_accounts/send_email"
      type: "POST"
      data: @toJSON()
      dataType : "json"
    })
