window.Emails = Backbone.Collection.extend({
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
      return email.attributes.thread[0].id != id;
    });

    this.remove(modelsToRemove);
  }
})
