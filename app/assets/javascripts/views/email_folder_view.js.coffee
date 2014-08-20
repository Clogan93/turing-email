window.EmailFolderView = Backbone.View.extend(    
    template: _.template("""
    <%= label_type === \"system\" ? \"\" : \"<li><a href='#label#\" + id + \"'>\" + name + \"</a></li>\" %>
    """)

    initialize: ->
        @model.on "change", @render, this
        return

    render: ->
        @$el.html @template(@model.toJSON())
        this
)