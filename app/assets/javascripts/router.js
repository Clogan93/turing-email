window.EmailApp = new (Backbone.Router.extend({
  routes: {
    "": "index",
    ":id": "show",
    "test": "test"
  },

  initialize: function(){
    this.emailItems = new EmailItems();
    this.emailsView = new EmailsView({collection: this.emailItems});
    this.emailsView.render();
  },

  test: function() {
    alert("test");
  },

  index: function(){
    $('#app').html(this.emailsView.el);
    this.emailItems.fetch();
  },

  start: function(){
    Backbone.history.start();
  },

  show: function(id){
    this.emailItems.focusOnEmailItem(id);
  }
}));