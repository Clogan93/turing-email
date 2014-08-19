window.EmailView = Backbone.View.extend({
  template: _.template('<div class="row" class="<%= thread[0].status %><%= thread[0].seen == true ? "" : "seen" %>">' +
    '<h3>' +
    '<div class="col-md-3"><%= thread[0].from_address %></div>' +  
    '<div class="col-md-3"><a href="#email#<%= thread[0].id %>"><%= thread[0].subject %></a></div>' +
    '<div class="col-md-4"><%= thread[0].snippet %></div>' +
    '<div class="col-md-2"><%= thread[0].date.substring(0, 10) %></div>' +
    '</h3>' +
    '</div>' +
    '<div class="email_body" style="display:none">' +
      '<div class="row">' +
        '<div class="col-md-11"><p style="word-wrap: break-word; padding-top: 2.5%;"><pre><%= thread[0].text_part %></pre></p></div>' +
      '</div>' +
      '<br />' +
      '<br />' +
      '<br />' +
      '<div class="row">' +
      '<div class="col-md-2"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">Reply</button></div>' +
      '<div class="col-md-9"><button type="button" class="btn btn-primary pull-right" data-toggle="modal" data-target="#myModal">Forward</button></div>' +
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

