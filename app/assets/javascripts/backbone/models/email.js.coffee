class TuringEmailApp.Models.Email extends Backbone.Model
  setSeen: ->
    @set seen: true
    @save()
