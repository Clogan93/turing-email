window.EmailView = Backbone.View.extend({
  template: _.template('<h3 class="email_header <%= status %><%= read == true ? "" : " read" %>">' +
    '<%= from_address %> ' +  
    '<a class="email_link" href="#<%= id %>"><%= subject %></a>' +
    '<span class="email_preview_text"><%= body.substring(0, 50) %></span>' +
    '<span class="email_date_text"><%= created_at.substring(0, 10) %></span>' +
    '</h3>' +
    '<div class="email_body" style="display:none">' +
    '<br /><%= body %></div><br /><a href="#test">Test</a><a href="#test2">Test2</a>'),

  events: {
    'click a': 'toggleStatus'
  },

  initialize: function(){
    this.model.on('change', this.render, this);
    this.model.on('destroy hide', this.remove, this);
  },

  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  },

  remove: function(){
    this.$el.remove();
  },

  toggleStatus: function(){
    this.model.toggleStatus()
  }
});

