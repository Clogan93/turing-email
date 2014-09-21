class TuringEmailApp.Models.Email extends Backbone.Model
  initialize: (options) ->
    @url = options.url if options?.url?
