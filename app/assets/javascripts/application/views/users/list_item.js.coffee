class App.Views.Users.ListItem extends App.View
  template: HandlebarsTemplates['users/list_item']
  tagName: 'tr'

  events: "click [data-role=remover]": "deleteUser"

  render: ->
    @$el.html(@template(@serialize()))

  deleteUser: ->
    if confirm("Are you sure you wish to remove this record?")
      @model.destroy().done () =>
          @remove()
        .fail () =>
          alert("Can't remove record")

  serialize: ->
    serialized = @model.toJSON()
    serialized
