window.EmailApp = new (Backbone.Router.extend({
  routes: {
    "": "index",
    "label#:id": "test",
    "email#:id": "show"
  },

  initialize: function(){
    console.log("1");
    this.emails = new Emails();
    console.log("2");
    this.inboxView = new InboxView({collection: this.emails});
    this.inboxView.render();
    console.log("3");
  },

  index: function(){
    console.log("4");
    $('#app').html(this.inboxView.el);
    this.emails.fetch({ 
      success: function (collection, response, options) {
        /* Set the inbox count to the number of emails in the inbox. */
        $("#inbox_count_badge").html(collection.length);
      }
    });
  },

  start: function(){
    Backbone.history.start();
  },

  test: function(id) {
    console.log(id);
    $('#app').html("<div>Here will be the emails for label " + id + ".</div>");
  },

  show: function(id){
    $(".email_body").show();
    $(".email_link").hide();
    $(".email_preview_text").hide();

    $(".reply_button").click(function() {
      $("#dialog").dialog("open");
    });

    $(".forward_button").click(function() {
      $("#dialog").dialog("open");
    });

    this.emails.focusOnEmail(id);

  }

}));