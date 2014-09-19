class TuringEmailApp.Models.User extends Backbone.Model
  url: "/api/v1/users/current"

  email:
    required: true
    pattern: "email"
