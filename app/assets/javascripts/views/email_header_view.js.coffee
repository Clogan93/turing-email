window.EmailHeaderView = Backbone.View.extend(
    template: _.template("""
    <tr>
        <h3>
            <td class="first_column">
                <%= email_thread.emails[0].email.from_name == null ? email_thread.emails[0].email.from_address : email_thread.emails[0].email.from_name %>
            </td>
            <td class="second_column">
                <a href=\"#email#<%= email_thread.emails[0].email.uid %>\">
                    <%= email_thread.emails[0].email.subject == \"\" ? \"(no subject)\" : email_thread.emails[0].email.subject %>
                </a>
                <span class="email_snippet"><%= email_thread.emails[0].email.snippet %></span>
            </td>
            <td class="third_column">
                <%= (new Date(email_thread.emails[0].email.date)).setHours((new Date(email_thread.emails[0].email.date)).getHours()+18) > Date.now() ? email_thread.emails[0].email.date.split("T")[1].substring(0, 5) : email_thread.emails[0].email.date.substring(0, 10) %>
            </td>
        </h3>
    </tr>
    """)

    initialize: ->
        @model.on "change", @render, this
        @model.on "destroy hide", @remove, this
        return

    render: ->
        console.log @model.toJSON()
        try
            if EmailApp.Models.user.attributes.user.email == @model.get("email_thread").emails[0].email.from_address
                @model.attributes.email_thread.emails[0].email.from_name = "me"
        catch error
            console.log error
        @$el.html @template(@model.toJSON())
        this

    remove: ->
        @$el.remove()
        return
)