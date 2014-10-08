TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.AttachmentsReportView extends Backbone.View
  template: JST["backbone/templates/reports/attachments_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    googleChartData = @getGoogleChartData()
      
    @$el.html(@template(googleChartData))

    @renderGoogleChart googleChartData

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

  addContentTypeStatsToRunningAverage: (stats, runningAverages, runningAverageKey) ->
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

  renderGoogleChart: (googleChartData) ->
    google.load('visualization', '1.0',
                 callback: => @drawCharts(googleChartData)
                 packages: ["corechart"])

  drawCharts: (googleChartData) ->
    @drawChart googleChartData.numAttachmentsGChartData, "num_attachments_chart_div", "Number of Attachments"
    @drawChart googleChartData.averageFileSizeGChartData, "average_file_size_chart_div", "Average File Size", true

  drawChart: (data, divID, chartTitle, humanizeFileSize=false) ->
    options =
      title: chartTitle
      legend:
        position: "none"

      hAxis:
        titleTextStyle:
          color: "black"

      vAxis:
        titleTextStyle:
          color: "black"

    chart = new google.visualization.ColumnChart($("#" + divID)[0])
    dataTable = google.visualization.arrayToDataTable(data)
    if humanizeFileSize
      @humanizeFileSizeGChartData dataTable
      @humanizeFileSizeGChartAxis chart, dataTable, options
    chart.draw dataTable, options

  humanizeFileSizeGChartAxis: (chart, dataTable, options) ->
    # get the axis values and reformat them
    runOnce = google.visualization.events.addListener(chart, "ready", =>
      google.visualization.events.removeListener runOnce
      boundingBox = undefined
      val = undefined
      formattedVal = undefined
      suffix = undefined
      ticks = []
      cli = chart.getChartLayoutInterface()
      i = 0

      while boundingBox = cli.getBoundingBox("vAxis#0#gridline#" + i)
        val = cli.getVAxisValue(boundingBox.top)
        
        # sometimes, the axis value falls 1/2 way though the pixel height of the gridline,
        # so we need to add in 1/2 the height
        # this assumes that all axis values will be integers
        val = cli.getVAxisValue(boundingBox.top + boundingBox.height / 2)  unless val is parseInt(val)
        
        # convert from base-10 counting to 2^10 counting
        fileSizePower = 0

        while val >= 1000
          val /= 1000
          fileSizePower++
        formattedVal = val
        val *= Math.pow(1024, fileSizePower)
        fileSizeInfo = @getFileSizeSuffix(fileSizePower, formattedVal)
        suffix = fileSizeInfo.suffix
        formattedVal = fileSizeInfo.formattedVal
        ticks.push
          v: val
          f: formattedVal + suffix

        i++
      options.vAxis = options.vAxis or {}
      options.vAxis.ticks = ticks
      chart.draw dataTable, options
      return
    )

  humanizeFileSizeGChartData: (data) ->
    # custom format data values
    i = 0

    while i < data.getNumberOfRows()
      val = data.getValue(i, 1)
      suffix = undefined
      fileSizePower = 0
      formattedVal = val

      while formattedVal >= 1024
        formattedVal /= 1024
        fileSizePower++
      fileSizeInfo = @getFileSizeSuffix(fileSizePower, formattedVal)
      suffix = fileSizeInfo.suffix
      formattedVal = fileSizeInfo.formattedVal
      
      # round to nearest decimal
      formattedVal = (Math.round(formattedVal * 10) / 10) + suffix
      data.setFormattedValue i, 1, formattedVal
      i++

  getFileSizeSuffix: (fileSizePower, formattedVal) ->
    switch fileSizePower
      when 0
        suffix = "B"
      when 1
        suffix = "KB"
      when 2
        suffix = "MB"
      when 3
        suffix = "GB"
      else
        
        # format to GB
        while fileSizePower > 3
          formattedVal *= 1024
          fileSizePower--
        suffix = "GB"
    suffix: suffix
    formattedVal: formattedVal
