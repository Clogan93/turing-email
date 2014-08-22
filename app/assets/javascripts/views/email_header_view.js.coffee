window.EmailHeaderView = Backbone.View.extend(
    template: _.template("""
    <div class=\"email_information_header row<%= email_thread.emails[0].email.status %><%= email_thread.emails[0].email.seen == true ? \"\" : \" seen\" %>\">
        <h3>
            <div class=\"col-md-3\">
                <%= email_thread.emails[0].email.from_address %>
            </div>
            <div class=\"col-md-3\">
                <a href=\"#email#<%= email_thread.emails[0].email.id %>\">
                    <%= email_thread.emails[0].email.subject == \"\" ? \"(no subject)\" : email_thread.emails[0].email.subject %>
                </a>
            </div>
            <div class=\"col-md-4\">
                <%= email_thread.emails[0].email.snippet %>
            </div>
            <div class=\"col-md-2\">
                <%= email_thread.emails[0].email.date.substring(0, 10) %>
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