TuringEmailApp.Views.Emails ||= {}

class TuringEmailApp.Views.Emails.EmailView extends Backbone.View
  template: _.template("""
    <div class=\"email_subject\">
        <%= emails[0].email.subject == \"\" ? \"(no subject)\" : emails[0].email.subject %>
    </div>
    <% _.each(emails, function(email_info, index) { %>
        <div class='email<%= emails.length > 1 && index < emails.length - 1 ? \" collapsed_email'\" : \"'\" %>">
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
            <div class="email_body" <%= emails.length > 1 && index < emails.length - 1 ? \"style='display:none;'\" : \"\" %> >
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
    return this

  bind_collapsed_email_thread_functionality: ->
    $(".email").click ->
      $(this).find(".email_body").show()
      $(this).removeClass("collapsed_email")
      $(this).siblings(".email").each ->
        $(this).addClass "collapsed_email"
        $(this).find(".email_body").hide()

  remove: ->
    @$el.remove()
    return

  toggleStatus: ->
    @model.toggleStatus()
    return

  destroy: () ->
    @model.destroy()
    this.remove()

    return false
