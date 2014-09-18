class TuringEmailApp.Models.AttachmentsReport extends Backbone.Model
  url: "/api/v1/email_reports/attachments_report"

  parse: (response, options) ->
    console.log "Parsing"
    parsedResponse = {}

    data = { 
      numAttachmentsData : []
      averageFileSizeAttachmentsData : []
    }

    for contentType, stats of response["content_type_stats"]
      data.numAttachmentsData.push([contentType, stats.num_attachments])
      data.averageFileSizeAttachmentsData.push([contentType, stats.average_file_size])

    data.numAttachmentsData = @translateContentType data.numAttachmentsData,
                                                    ['Attachment Type', 'Number of attachments']
    data.averageFileSizeAttachmentsData = @translateContentType data.averageFileSizeAttachmentsData,
                                                                ['Attachment Type', 'Average File Size']

    parsedResponse["data"] = data

    console.log "Returning parsing"
    return parsedResponse

  translateContentType: (attachmentsData, header) ->
    newAttachmentsData = {}
    newAttachmentsData["Document"] = 0
    
    for attachmentData in attachmentsData
      contentTypeParts = attachmentData[0].split("/")
      value = attachmentData[1]
      
      if contentTypeParts[0] is "image"
        if newAttachmentsData["Images"]?
          newAttachmentsData["Images"] += value
        else 
          newAttachmentsData["Images"] = value
      else
        lastIndex = parseInt(contentTypeParts.length) - 1
        contentType = contentTypeParts[lastIndex]
        
        switch contentType
          when "ics" then newAttachmentsData["Calendar Invite"] = value
          when "pdf" then newAttachmentsData["PDF"] = value
          when "vnd.openxmlformats-officedocument.presentationml.presentation" then newAttachmentsData["Presentation"] = value
          when "vnd.openxmlformats-officedocument.spreadsheetml.sheet" then newAttachmentsData["Spreadsheet"] = value
          when "msword" then newAttachmentsData["Document"] += value
          when "vnd.openxmlformats-officedocument.wordprocessingml.document" then newAttachmentsData["Document"] += value
          when "zip" then newAttachmentsData["ZIP"] = value
          when "octet-stream" then newAttachmentsData["Binary"] = value
          else newAttachmentsData[contentType] = value
    
    attachmentData = []
    attachmentData.push(header)
    
    for key, value of newAttachmentsData
      attachmentData.push([key, value])
    
    return attachmentData
