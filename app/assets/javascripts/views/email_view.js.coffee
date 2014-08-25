window.EmailView = Backbone.View.extend(    
    template: _.template("""
    <div class=\"email_subject\">
        <%= email_thread.emails[0].email.subject == \"\" ? \"(no subject)\" : email_thread.emails[0].email.subject %>
    </div>
    <% _.each(email_thread.emails, function(email_info, index) { %>
        <div class='email<%= email_thread.emails.length > 1 && index < email_thread.emails.length - 1 ? \" collapsed_email'\" : \"'\" %>">
            <div class=\"email_information\">
                <div class=\"col-md-3\">
                    <%= email_info.email.from_name == \"\" ? email_info.email.from_address : email_info.email.from_name %>
                </div>
                <div class=\"col-md-4\">
                    <%= email_info.email.snippet %>
                </div>
                <div class=\"col-md-2\">
                    <%= email_info.email.date == null ? \"\" : email_info.email.date.substring(0, 10) %>
                </div>
            </div>
            <br />
            <br />
            <br />
            <div class="email_body" <%= email_thread.emails.length > 1 && index < email_thread.emails.length - 1 ? \"style='display:none;'\" : \"\" %> >
                <div class="row">
                    <div class="col-md-11">
                        <pre><%= email_info.email.text_part == null ? \"\" : email_info.email.text_part %></pre>
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
        </div>
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