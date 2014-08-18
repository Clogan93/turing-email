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
    console.log(id);
    $('#app').html("<div>Here will be the emails for label " + id + ".</div>");
  },

  show: function(id){
    this.emails.focusOnEmail(id);
    $(".email_body").show();
    $(".email_link").hide();
    $(".email_preview_text").hide();

    $(".reply_button").click(function() {
      $("#dialog").dialog("open");
    });

    $(".forward_button").click(function() {
      $("#dialog").dialog("open");
    });

  }

}));