class TuringEmailApp.Models.EmailThread extends Backbone.Model

	setSeen: ->
		for email in @.get("emails")
			console.log email.uid
