window.Label = Backbone.Collection.extend({
  model: Email,
  url: '/emails',

  initialize: function(){
    this.on('remove', this.hideModel, this);
  },

  hideModel: function(model){
    model.trigger('hide');
  },

  focusOnEmail: function(id) {
    var modelsToRemove = this.filter(function(email){
      return email.id != id;
    });

    this.remove(modelsToRemove);
  }
})
