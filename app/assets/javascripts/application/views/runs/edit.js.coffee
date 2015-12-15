class App.Views.Runs.Edit extends App.View
  template: HandlebarsTemplates['runs/edit']

  events: 'submit #run_form': 'createRun'

  initialize: ->
    @listenTo @model, "change:distance", _.bind(@updateDistance, @)
    @listenTo @model, "change:run_time", _.bind(@updateDistance, @)
    @isManager = ['user_manager', 'admin'].indexOf(@currentUser().get("role")) >= 0

  createRun: (evt)->
    evt.preventDefault()
    date = $("#date").val()
    hours = parseInt($("#hours").val())
    minutes = parseInt($("#minutes").val())
    seconds = parseInt($("#seconds").val())
    hours = 0 if isNaN(hours)
    minutes = 0 if isNaN(minutes)
    time = hours*60*60 + minutes*60 + seconds
    distance = $("#distance").val()
    @model.set("run_date", date)
    @model.set("run_time", time)
    @model.set("distance", distance)
    @model.set("user_id", @$el.find("#user").val()) if @isManager
    @model.save().done =>
        @$el.find(".success").html("Run saved")
        @$el.find(".error").html("")
      .fail =>
        @$el.find(".success").html("")
        @$el.find(".error").html("Unable to save run")

  render: ->
    if @isManager
      @users = new App.Collections.Users()
      @users.fetch().done () =>
        @$el.html @template(@serialize())
        $('#run_form').parsley()
    else
      @$el.html @template(@serialize())
      $('#run_form').parsley()

  updateDistance: ->
    speed = if @model.get("run_time") > 0
        @averageSpeed()
      else
        0
    @$el.find("#averageSpeed").html("#{@averageSpeed()} km/h")

  averageSpeed: ->
    avg_speed = ((@model.get("distance")/1000) / ((@model.get("run_time")/60)/60)).toFixed(2)
    if isNaN(avg_speed)
      0
    else
      avg_speed

  serialize: ->
    if @model.isNew()
      serialized = {
        average_speed: @averageSpeed()
      }
    else
      serialized = @model.toJSON()
      serialized.run_date = moment(@model.get("run_date")).format("YYYY-MM-DD")
      hours_to_seconds = moment(@model.get("run_time")*1000).format("HH:mm:ss").split(':')
      serialized.run_seconds = hours_to_seconds.pop()
      serialized.run_minutes = hours_to_seconds.pop()
      serialized.run_hours = hours_to_seconds.pop()
      serialized.average_speed = @averageSpeed()
    serialized.showsUser = @isManager
    serialized.users = @users.toJSON() if @isManager
    serialized
