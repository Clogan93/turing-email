window.EmailItem = Backbone.Model.extend({
  toggleStatus: function(){
    if(this.get('read') == false){
      this.set({'read': true});
    }else{
      this.set({'read': false});
    }

    this.save();
  }
});
