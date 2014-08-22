window.EmailHeaderView = Backbone.View.extend(
    template: _.template("""
    <tr>
        <h3>
            <td class="first_column">
                <%= thread[0].from_name == \"\" ? thread[0].from_address : thread[0].from_name %>
            </td>
            <td class="second_column">
                <a href=\"#email#<%= thread[0].id %>\">
                    <%= thread[0].subject == \"\" ? \"(no subject)\" : thread[0].subject %>
                </a>
                <span class="email_snippet"><%= thread[0].snippet %></span>
            </td>
            <td class="third_column">
                <%= thread[0].date.substring(0, 10) %>
            </td>
        </h3>
    </tr>
    """)

    initialize: ->
        @model.on "change", @render, this
        @model.on "destroy hide", @remove, this
        return

    render: ->
        @$el.html @template(@model.toJSON())
        this

    remove: ->
        @$el.remove()
        return
)