class TuringEmail.Models.Post extends Backbone.Model
  paramRoot: 'post'

  defaults:
    title: null
    content: null

class TuringEmail.Collections.PostsCollection extends Backbone.Collection
  model: TuringEmail.Models.Post
  url: '/posts'
