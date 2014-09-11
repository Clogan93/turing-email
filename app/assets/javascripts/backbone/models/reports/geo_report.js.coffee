class TuringEmailApp.Models.GeoReport extends Backbone.Model
  url: "/api/v1/emails/ip_stats"

  parse: (response, options) ->
    parsedResponse = {}

    data = { 
      geoData : [
        ['City', 'Popularity']
      ]
    }

    for geoDataPoint in response
      city = geoDataPoint["ip_info"]["city"]
      num_emails = geoDataPoint["num_emails"]
      data.geoData.push([city, num_emails])

    parsedResponse["data"] = data

    return parsedResponse
