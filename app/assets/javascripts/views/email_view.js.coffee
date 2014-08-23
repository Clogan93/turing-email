window.EmailView = Backbone.View.extend(    
    template: _.template("""
    <% _.each(email_thread.emails, function(email_info) { %>
        <div class=\"email_body\">
            <h3>
                <div class=\"col-md-3\">
                    <%= email_info.email.from_name == \"\" ? email_info.email.from_address : email_info.email.from_name %>
                </div>
                <div class=\"col-md-3\">
                    <a href=\"#email#<%= email_info.email.uid %>\">
                        <%= email_info.email.subject == \"\" ? \"(no subject)\" : email_info.email.subject %>
                    </a>
                </div>
                <div class=\"col-md-4\">
                    <%= email_info.email.snippet %>
                </div>
                <div class=\"col-md-2\">
                    <%= email_info.email.date == null ? \"\" : email_info.email.date.substring(0, 10) %>
                </div>
            </h3>
            <div class="row">
                <div class="col-md-11">
                    <pre>
                        <%= email_info.email.text_part %>
                    </pre>
                </div>
            </div>
            <br />
            <br />
            <br />
            <div class=\"row\">
                <div class=\"col-md-2\">
                    <button type=\"button\" class=\"btn btn-primary\" data-toggle=\"modal\" data-target=\"#myModal\">Reply</button>
                </div>
                <div class=\"col-md-9\">
                    <button type=\"button\" class=\"btn btn-primary pull-right\" data-toggle=\"modal\" data-target=\"#myModal\">Forward</button>
                </div>
            </div>
        </div>
        <br />
        <br />
    <% }); %>
    <br />
    """)

    events:
        "click a": "toggleStatus"

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

    toggleStatus: ->
        @model.toggleStatus()
        return
)