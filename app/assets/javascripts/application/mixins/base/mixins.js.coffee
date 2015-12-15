App.Mixins =

  extend: (mixin) ->
    for key, value of mixin when key not in ['extend','include']
      @[key] = value
    mixin.extended?.apply(@)
    @

  include: (mixin) ->
    for key, value of mixin when key not in ['extend','include']
      @::[key] = value
    mixin.included?.apply(@)
    @

  authToken: ->
    authToken = localStorage.getItem("authToken")
    if authToken?
      JSON.parse(authToken).token
    else
      null

  currentUser: ->
    currentUser = localStorage.getItem("currentUser")
    if currentUser?
      new App.Models.User(JSON.parse(currentUser))
    else
      null
