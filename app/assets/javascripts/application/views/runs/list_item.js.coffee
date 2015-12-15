class App.Views.Runs.ListItem extends App.View
  template: HandlebarsTemplates['runs/list_item']
  tagName: 'tr'

  events: "click [data-role=remover]": "deleteRun"

  render: ->
    @$el.html(@template(@serialize()))

  deleteRun: ->
    if confirm("Are you sure you wish to remove this record?")
      @model.destroy().done () =>
          @remove()
        .fail () =>
          alert("Can't remove record")

  serialize: ->
    serialized = @model.toJSON()
    serialized.run_date = moment(@model.get("run_date")).format("DD-MM-YYYY")
    serialized.average_speed = ((@model.get("distance")/1000) / ((@model.get("run_time")/60)/60)).toFixed(2)
    serialized.run_time = moment(@model.get("run_time")*1000).format("HH:mm:ss")
    serialized.showsUser = ['user_manager', 'admin'].indexOf(@currentUser().get("role")) >= 0
    serialized
