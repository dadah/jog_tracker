class App.Views.Users.Index extends App.View
  template: HandlebarsTemplates['users/index']
  views: []

  render: ->
    @$el.html(@template)
    @collection.fetch().done _.bind(@renderUsers, @)

  renderUsers: ->
    @collection.each _.bind(@addUser, @)

  addUser: (model)->
    view = new App.Views.Users.ListItem(model: model)
    @views.push view
    @$el.find("[data-role=users]").append view.el
    view.render()

  remove: ->
    _.each @views, (view) ->
      view.remove()
    Backbone.View.prototype.remove.call(@)
