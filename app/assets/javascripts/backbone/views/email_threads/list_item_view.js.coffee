TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: _.template("""
    <tr>
        <h3>
            <td class="first_column">
                <%= emails[0].from_name == null ? emails[0].from_address : emails[0].from_name %>
            </td>
            <td class="second_column">
                <a href=\"#email#<%= emails[0].uid %>\">
                    <%= emails[0].subject == \"\" ? \"(no subject)\" : emails[0].subject %>
                </a>
                <span class="email_snippet"><%= emails[0].snippet %></span>
            </td>
            <td class="third_column">
                <%= (new Date(emails[0].date)).setHours((new Date(emails[0].date)).getHours()+18) > Date.now() ? (new Date(emails[0].date)).toLocaleTimeString(navigator.language, {hour: '2-digit', minute:'2-digit'}) : emails[0].date.substring(0, 10) %>
            </td>
        </h3>
    </tr>
    """)

  initialize: ->
    @model.on "change", @render, this
    @model.on "destroy hide", @remove, this
    return

  render: ->
    try
      if TuringEmailApp.user.get("email") == @model.get("emails")[0].from_address
        @model.attributes.emails[0].from_name = "me"
    catch error
      console.log error
    @$el.html @template(@model.toJSON())
    this

  remove: ->
    @$el.remove()
    return