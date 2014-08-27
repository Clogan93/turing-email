window.Email = Backbone.Model.extend(toggleStatus: ->
    if @get("seen") is false
        @set seen: true
    else
        @set seen: false
    @save()
    return
)