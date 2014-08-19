window.Email = Backbone.Model.extend({
  toggleStatus: function(){
    if(this.get('seen') == false){
      this.set({'seen': true});
    }else{
      this.set({'seen': false});
    }

    this.save();
  }
});
