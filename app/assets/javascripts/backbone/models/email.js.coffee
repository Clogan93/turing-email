class TuringEmailApp.Models.Email extends Backbone.Model
  toggleStatus: ->
    if @get("seen") is false
      @set seen: true
    else
      @set seen: false
    @save()
