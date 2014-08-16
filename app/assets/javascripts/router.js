window.MessageApp = new (Backbone.Router.extend({
  routes: {
    "": "index",
    ":id": "show",
    "test": "test"
  },

  initialize: function(){
    this.messageItems = new MessageItems();
    this.messagesView = new MessagesView({collection: this.messageItems});
    this.messagesView.render();
  },

  test: function() {
    alert("test");
  },

  index: function(){
    $('#app').html(this.messagesView.el);
    this.messageItems.fetch();
  },

  start: function(){
    Backbone.history.start();
  },

  show: function(id){
    this.messageItems.focusOnMessageItem(id);
  }
}));