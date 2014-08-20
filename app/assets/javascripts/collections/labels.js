window.Labels = Backbone.Collection.extend({
  model: Label,
  url: '/labels',

  initialize: function(){
    this.on('remove', this.hideModel, this);
  },

  hideModel: function(model){
    model.trigger('hide');
  }
})
