TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.WordCountReportView extends Backbone.View
  template: JST["backbone/templates/reports/word_count_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    googleChartData = @getGoogleChartData()

    @$el.html(@template(googleChartData))

    return this

  getGoogleChartData: ->
    data =
      wordCountsGChartData: [["Count", "Received", "Sent"]].concat(
        @model.get("word_counts")
      )

    return data
