class TuringEmailApp.Models.ContactsReport extends Backbone.Model
  url: "/api/v1/email_reports/contacts_report"

  parse: (response, options) ->
    parsedResponse = {}

    incomingEmailData = { 
      people : [],
      title : "Incoming Email Volume Chart"
    }
    
    for recipientAddress, count of response["top_recipients"]
      incomingEmailData.people.push([recipientAddress, count])

    parsedResponse["incomingEmailData"] = incomingEmailData

    outgoingEmailData = { 
      people : [],
      title : "Outgoing Email Volume Chart"
    }
    
    for senderAddress, count of response["top_senders"]
      outgoingEmailData.people.push([senderAddress, count])
    
    parsedResponse["outgoingEmailData"] = outgoingEmailData

    return parsedResponse
