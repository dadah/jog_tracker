class App.Router extends Backbone.Router

  el: "#container"
  menuEl: "#menu"
  currentView: null
  menuView: null

  swapView: (view) ->
    @currentView?.remove()
    @currentView = view
    $(@el).html(view.el)
    view.render()

  route: (route, name, callback) ->
    unless callback
      callback = this[name]

    wrappedCallback = _.bind ->
      authToken = @authToken()
      if @ignoreAuth?.indexOf(route) > -1
        if authToken?
          Backbone.history.navigate("/runs", trigger: true)
          return
        else
          @menuView?.remove()
          @menuView = null
      else
        if authToken?
          unless @menuView?
            view = new App.Views.Menu.Index()
            $(@menuEl).html(view.el)
            view.render()
            @menuView = view
        else
          Backbone.history.navigate("", trigger: true)
          return

      if callback
        callback.apply @, arguments
    , @

    Backbone.Router.prototype.route.call @, route, name, wrappedCallback

_.extend App.Router.prototype, App.Mixins
