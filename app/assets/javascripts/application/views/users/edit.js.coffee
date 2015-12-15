class App.Views.Users.Edit extends App.View
  template: HandlebarsTemplates['users/edit']

  events: 'submit #user_form': 'createUser'

  createUser: (evt)->
    evt.preventDefault()
    email = $("#email").val()
    name = $("#name").val()
    role = $("#role").val()
    password = $("#password").val() if $("#password").val().trim()?
    @model.set("email", email)
    @model.set("name", name)
    @model.set("role", role)
    @model.set("password", password) if password?
    @model.save().done =>
        @$el.find(".success").html("User saved")
        @$el.find(".error").html("")
      .fail =>
        @$el.find(".success").html("")
        @$el.find(".error").html("Unable to save user")

  render: ->
    @$el.html @template(@serialize())
    $('#user_form').parsley()

  serialize: ->
    if @model.isNew()
      serialized = {}
    else
      serialized = @model.toJSON()
    serialized.roles = ["user", "user_manager"]
    serialized.roles.push "admin" if @currentUser().get("role") is "admin"
    serialized
