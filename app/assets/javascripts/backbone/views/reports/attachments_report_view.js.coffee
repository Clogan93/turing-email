TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.AttachmentsReportView extends Backbone.View
  template: JST["backbone/templates/reports/attachments_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    googleChartData = @getGoogleChartData()
      
    @$el.html(@template(googleChartData))

    TuringEmailApp.showReports()
    return this
    
  getGoogleChartData: ->
    contentTypeStats = @model.get("content_type_stats")
    reducedContentTypeStats = @getReducedContentTypeStats(contentTypeStats)

    data =
      averageFileSize: @model.get("average_file_size")
      numAttachmentsGChartData: [["Attachment Type", "Number of Attachments"]].concat(
        _.zip(_.keys(reducedContentTypeStats), _.pluck(reducedContentTypeStats, "numAttachments")).sort((a,b) ->
          a[0].localeCompare(b[0])
        )
      )
      averageFileSizeGChartData: [["Attachment Type", "Average File Size"]].concat(
        _.zip(_.keys(reducedContentTypeStats), _.pluck(reducedContentTypeStats, "averageFileSize")).sort((a,b) ->
          a[0].localeCompare(b[0])
        )
      )
      
    return data

  addContentTypeStatsToRunningAverage:(stats, runningAverages, runningAverageKey) ->
    runningAverages[runningAverageKey] ?= {}
    runningAverage = runningAverages[runningAverageKey]
    
    runningAverage.numAttachments ?= 0
    runningAverage.averageFileSize ?= 0

    runningAverage.averageFileSize = (runningAverage.averageFileSize * runningAverage.numAttachments +
                                      stats.average_file_size * stats.num_attachments) / 
                                      (stats.num_attachments + runningAverage.numAttachments)
    runningAverage.numAttachments += stats.num_attachments
    
  getReducedContentTypeStats:(contentTypeStats) ->
    contentTypeReductionMap =
      "ics": "Calendar Invite"
      "zip": "Zip"
      "pdf": "PDF"
      "msword": "Document"
      "vnd.openxmlformats-officedocument.wordprocessingml.document": "Document"
      "vnd.openxmlformats-officedocument.presentationml.presentation": "Presentation"
      "vnd.openxmlformats-officedocument.spreadsheetml.sheet": "Spreadsheet"
      
    reducedContentTypeStats = {}
    
    for contentType, stats of contentTypeStats
      contentTypeParts = contentType.split("/")
      type = contentTypeParts[0].toLowerCase()
      subtype = contentTypeParts[1].toLowerCase()

      reducedType = if type is "image" then "Image" else (contentTypeReductionMap[subtype] ? "Other")
      @addContentTypeStatsToRunningAverage(stats, reducedContentTypeStats, reducedType)
 
    return reducedContentTypeStats