class TuringEmailApp.Models.WordCountReport extends Backbone.Model
  fetch: (options) ->
    attributes =
      wordCountData : [
        ['Count', 'Received', 'Sent'],
        ['< 10',  33,      17],
        ['< 30',  4,      27],
        ['< 50',  3,       26],
        ['< 100',  11,      14],
        ['< 200',  14,      12],
        ['More',  34,      3]
      ]

    @set attributes
    options?.success?(this, {}, options)
