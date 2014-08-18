window.EmailView = Backbone.View.extend({
  template: _.template('<h3 class="email_header <%= status %><%= seen == true ? "" : " read" %>">' +
    '<%= from_address %> ' +  
    '<a class="email_link" href="#email#<%= id %>"><%= subject %></a>' +
    '<span class="email_preview_text"><%= snippet %></span>' +
    '<span class="email_date_text"><%= date.substring(0, 10) %></span>' +
    '</h3>' +
    '<div class="email_body" style="display:none">' +
    '<br /><%= text_part %>' +
    '<br />' +
    '<br />' +
    '<br />' +
    '<div align="center" class="send_email_button reply_button">' +
    '<span>Reply</span>' +
    '</div>' +
    '<div align="center" class="send_email_button forward_button">' +
    '<span>Forward</span>' +
    '</div>' +
    '</div><br />'),

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

