class TuringEmailApp.Models.User extends Backbone.Model
  url: "/api/v1/users/current"

  validate: (attrs, options) ->
  	if not attrs.email?
  		return "Email is required"
