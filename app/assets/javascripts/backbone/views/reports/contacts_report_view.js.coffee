TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.ContactsReportView extends Backbone.View
  template: JST["backbone/templates/reports/contacts_report"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    googleChartData = @getGoogleChartData()

    @$el.html(@template(googleChartData))

    TuringEmailApp.showReports()
    return this

  getGoogleChartData: ->
    topSenders = @model.get("top_senders")
    topRecipients = @model.get("top_recipients")
    
    data =
      topSenders: [["Person", "Percent"]].concat(
        _.zip(_.keys(topSenders), _.values(topSenders))
      )
      topRecipients: [["Person", "Percent"]].concat(
        _.zip(_.keys(topRecipients), _.values(topRecipients))
      )

    return data
