window.EmailApp = new (Backbone.Router.extend({
  routes: {
    "": "index",
    "test": "test",
    "test2": "test2",
    ":id": "show"
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

  test: function() {
    alert("test");
  },

  test2: function() {
    alert("test2");
  },

  show: function(id){
    alert("yo1")
    this.emails.focusOnEmail(id);
    $(".email_body").show();
    $(".email_link").hide();
    $(".email_preview_text").hide();
  }

}));