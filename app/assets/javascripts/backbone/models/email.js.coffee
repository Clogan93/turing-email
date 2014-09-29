class TuringEmailApp.Models.Email extends Backbone.Model
  @localDateString: (emailDateString) ->
    if emailDateString?
      emailDate = new Date(emailDateString)
      
      emailDatePlus18H = new Date(emailDateString)
      emailDatePlus18H.setHours(emailDate.getHours() + 18)

      if emailDatePlus18H > Date.now()
        return emailDate.toLocaleTimeString(navigator.language, {hour: "2-digit", minute: "2-digit"})
      else
        formattedDateStringComponents = emailDate.toDateString().split(" ")
        return formattedDateStringComponents[1] + " " + formattedDateStringComponents[2]
    else
      return ""

  sendEmail: ->
    $.ajax({
      url: "/api/v1/email_accounts/send_email"
      type: "POST"
      data: @toJSON()
      dataType : "json"
    })

  localDateString: ->
    TuringEmailApp.Models.Email.localDateString(@get("date"))
