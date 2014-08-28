TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListViewItem extends Backbone.View
  template: _.template("""
    <tr>
        <h3>
            <td class="first_column">
                <%= emails[0].email.from_name == null ? emails[0].email.from_address : emails[0].email.from_name %>
            </td>
            <td class="second_column">
                <a href=\"#email#<%= emails[0].email.uid %>\">
                    <%= emails[0].email.subject == \"\" ? \"(no subject)\" : emails[0].email.subject %>
                </a>
                <span class="email_snippet"><%= emails[0].email.snippet %></span>
            </td>
            <td class="third_column">
                <%= (new Date(emails[0].email.date)).setHours((new Date(emails[0].email.date)).getHours()+18) > Date.now() ? (new Date(emails[0].email.date)).toLocaleTimeString(navigator.language, {hour: '2-digit', minute:'2-digit'}) : emails[0].email.date.substring(0, 10) %>
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
        @model.attributes.emails[0].email.from_name = "me"
    catch error
      console.log error
    @$el.html @template(@model.toJSON())
    this

  remove: ->
    @$el.remove()
    return