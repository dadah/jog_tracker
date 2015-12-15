class App.Views.Reports.Base extends App.View
  template: HandlebarsTemplates["reports/chart"]

  events:
    "change [data-role=weekRange]": "setWeek"
    "change [data-role=user]": "setUser"

  initialize: ->
    currentUser = @currentUser()
    @isUser = currentUser.get("role") is 'user'
    @userId = currentUser.id
    @val = -10
    @buildData()

  initialValues: ->
    true

  buildData: () ->
    cursorDate = moment()
    cursorDate.add(@val, "month").startOf("week")
    @startDate = cursorDate.clone()
    @data = {}
    currentDate = moment()
    while(cursorDate.isBefore(currentDate))
      @data[cursorDate.format("YYYY-MM-DD")] = @initialValues()
      cursorDate.add(1, "week")

  render: ->
    if @isUser
      @build()
    else
      @users = new App.Collections.Users()
      @users.fetch().done () =>
        @build()

  build: ->
    @$el.html(@template(@serialize()))
    @buildChart()

  serialize: ->
    serialized = {
      isUser: @isUser
      users: []
      userId: @userId
    }

    unless @isUser
      serialized.users = @users.toJSON()

    serialized

  setWeek: (evt)->
    evt.preventDefault()
    el = $(evt.currentTarget)
    @val = -parseInt(el.val())
    @draw()

  draw: ->
    @buildData()
    @buildChart()

  setUser: (evt)->
    evt.preventDefault()
    @userId = $(evt.currentTarget).val()
    @draw()
