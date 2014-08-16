window.EmailItems = Backbone.Collection.extend({
  model: EmailItem,
  url: '/emails',

  initialize: function(){
    this.on('remove', this.hideModel, this);
  },

  hideModel: function(model){
    model.trigger('hide');
  },

  focusOnEmailItem: function(id) {
    var modelsToRemove = this.filter(function(emailItem){
      return emailItem.id != id;
    });

    this.remove(modelsToRemove);
  }
})
