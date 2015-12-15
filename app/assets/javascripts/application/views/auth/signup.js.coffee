class App.Views.Auth.Signup extends App.View
  template: HandlebarsTemplates['auth/signup']

  events:
    "submit #signup_form": "signup"

  initialize: ->

  signup: (evt)->
    evt.preventDefault()
    @model = new App.Models.User(
      name: $("#name").val(),
      email: $("#email").val(),
      password: $("#password").val()
    )
    @model.save().done () ->
        Backbone.history.navigate("/", trigger: true)
      .fail (response) =>
        @$el.find(".error").html(
          "Could not create the account! #{response?.responseJSON?.response}"
        )

  render: ->
    @$el.html(@template())
    $('#signup_form').parsley()
