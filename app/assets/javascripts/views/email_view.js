window.EmailView = Backbone.View.extend({
  template: _.template('<h3 class="<%= status %>"><input type=checkbox <%= read == true ? "checked=checked" : "" %>/> <a href="#<%= id %>"><%= subject %></a></h3><div class="email_body" style="display:none"><br /><%= body %></div><br />'),

  events: {
    'change input': 'toggleStatus'
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

