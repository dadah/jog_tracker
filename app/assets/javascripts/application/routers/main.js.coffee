class App.Routers.Main extends App.Router

  ignoreAuth: ['', 'signup']

  routes:
    "" : "index"
    "signup": "signup"
    "runs": "runs"
    "runs/new": "newRun"
    "runs/:run_id/edit": "editRun"
    "users": "users"
    "users/new": "newUser"
    "users/:user_id/edit": "editUser"
    "account": "account"
    "reports/distance": "distanceReport"
    "reports/speed": "speedReport"

  index: ->
    view = new App.Views.Auth.Index()
    @swapView(view)

  signup: ->
    view = new App.Views.Auth.Signup()
    @swapView(view)

  runs: ->
    collection = new App.Collections.Runs()
    view = new App.Views.Runs.Index(collection: collection)
    @swapView(view)

  newRun: ->
    model = new App.Models.Run()
    view = new App.Views.Runs.Edit(model: model)
    @swapView(view)

  editRun: (runId)->
    model = new App.Models.Run(id: runId)
    model.fetch().done () =>
        view = new App.Views.Runs.Edit(model: model)
        @swapView(view)
      .fail ->
        Backbone.history.navigate("/", trigger: true)

  users: ->
    collection = new App.Collections.Users()
    view = new App.Views.Users.Index(collection: collection)
    @swapView(view)

  newUser: ->
    model = new App.Models.User()
    view = new App.Views.Users.Edit(model: model)
    @swapView(view)

  editUser: (userId)->
    model = new App.Models.User(id: userId)
    model.fetch().done () =>
        view = new App.Views.Users.Edit(model: model)
        @swapView(view)
      .fail ->
        Backbone.history.navigate("/", trigger: true)

  account: ->
    view = new App.Views.Users.Edit(model: @currentUser())
    @swapView(view)

  distanceReport: ->
    collection = new App.Collections.Runs()
    view = new App.Views.Reports.Index(collection: collection)
    @swapView(view)

  speedReport: ->
    collection = new App.Collections.Runs()
    view = new App.Views.Reports.Speed(collection: collection)
    @swapView(view)
