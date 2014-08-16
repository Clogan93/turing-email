window.MessageItems = Backbone.Collection.extend({
  model: MessageItem,
  url: '/messages',

  initialize: function(){
    this.on('remove', this.hideModel, this);
  },

  hideModel: function(model){
    model.trigger('hide');
  },

  focusOnMessageItem: function(id) {
    var modelsToRemove = this.filter(function(messageItem){
      return messageItem.id != id;
    });

    this.remove(modelsToRemove);
  }
})
