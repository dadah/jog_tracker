class App.Views.Runs.Index extends App.View
  template: HandlebarsTemplates['runs/index']
  views: []

  events:
    "change [data-role^=filter]": "filterCollection"
    "click [data-role=clearFilters]": "clearFilters"

  initialize: ->
    @listenTo @collection, "reset", _.bind(@renderRuns, @)

  render: ->
    @$el.html(@template(@serialize()))
    @collection.fetch(reset: true)

  serialize: ->
    serialized = {}
    serialized.showsUser = ['user_manager', 'admin'].indexOf(@currentUser().get("role")) >= 0
    serialized

  renderRuns: ->
    @removeSubViews()
    @collection.each _.bind(@addRun, @)

  addRun: (model)->
    view = new App.Views.Runs.ListItem(model: model)
    @views.push view
    @$el.find("[data-role=runs]").append view.el
    view.render()

  remove: ->
    @removeSubViews()
    Backbone.View.prototype.remove.call(@)

  removeSubViews: ->
    _.each @views, (view) ->
      view.remove()

  filterCollection: (evt)->
    evt.preventDefault()
    start_value = moment($("[data-filter=starts_at]").val())
    end_value = moment($("[data-filter=ends_at]").val())
    params = {
      reset: true
      data: {}
    }
    if start_value.isValid() || end_value.isValid()
      params.data["starts_at"] = start_value.format("YYYY-MM-DD") if start_value.isValid()
      params.data["ends_at"] = end_value.format("YYYY-MM-DD") if end_value.isValid()
    @collection.fetch(params)

  clearFilters: (evt)->
    evt.preventDefault()
    $("[data-filter=starts_at]").val("")
    $("[data-filter=ends_at]").val("")
    $("[data-filter=starts_at]").trigger("change")
