window.EmailApp = new (Backbone.Router.extend({
  routes: {
    "": "index",
    "label#:id": "test",
    "email#:id": "show"
  },

  initialize: function(){
    this.emails = new Emails();
    this.inboxView = new InboxView({collection: this.emails});
    this.inboxView.render();
  },

  index: function(){
    $('#app').html(this.inboxView.el);
    this.emails.fetch();
  },

  start: function(){
    Backbone.history.start();
  },

  test: function(id) {
    alert(id);
  },

  show: function(id){
    alert("yo1")
    this.emails.focusOnEmail(id);
    $(".email_body").show();
    $(".email_link").hide();
    $(".email_preview_text").hide();
  }

}));