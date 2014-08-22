window.EmailHeaderView = Backbone.View.extend(
    template: _.template("""
    <div class=\"email_information_header row<%= thread[0].status %><%= thread[0].seen == true ? \"\" : \" seen\" %>\">
        <h3>
            <div class=\"col-md-3\">
                <%= thread[0].from_name == \"\" ? thread[0].from_address : thread[0].from_name %>
            </div>
            <div class=\"col-md-3\">
                <a href=\"#email#<%= thread[0].id %>\">
                    <%= thread[0].subject == \"\" ? \"(no subject)\" : thread[0].subject %>
                </a>
            </div>
            <div class=\"col-md-4\">
                <%= thread[0].snippet %>
            </div>
            <div class=\"col-md-2\">
                <%= thread[0].date.substring(0, 10) %>
            </div>
        </h3>
    </div>
    <br />
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