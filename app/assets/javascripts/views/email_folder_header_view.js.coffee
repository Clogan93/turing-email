window.EmailFolderHeaderView = Backbone.View.extend(    
    template: _.template("""
    <% _.each(gmail_label.name.split("/"), function(label_component) { %>

    	<%= label_component %>

    <% }); %>

    <%= gmail_label.label_type === \"system\" ? \"\" : \"<li><a href='#label#\" + gmail_label.label_id + \"'>\" + gmail_label.name + \"</a> <span class='badge'>\" + gmail_label.num_unread_threads + \"</span></li><br />\" %>
    """)

    initialize: ->
        @model.on "change", @render, this
        return

    render: ->
        console.log @model.toJSON()
        @$el.html @template(@model.toJSON())
        this
)