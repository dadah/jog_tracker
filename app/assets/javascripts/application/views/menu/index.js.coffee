class App.Views.Menu.Index extends App.View
  template: HandlebarsTemplates['menu/index']
  tagName: 'nav'
  className: 'navbar navbar-default'

  events: "click [data-role=logout]": "logout"

  render: ->
    @$el.html(@template(@serialize()))

  serialize: ->
    currentUser = @currentUser()
    serialized = currentUser.toJSON()
    serialized.canEditUsers = ['user_manager', 'admin'].indexOf(currentUser.get("role")) > -1
    serialized

  logout: (ev) ->
    ev.preventDefault()
    localStorage.removeItem("authToken")
    localStorage.removeItem("currentUser")
    Backbone.history.navigate("/", trigger: true)
