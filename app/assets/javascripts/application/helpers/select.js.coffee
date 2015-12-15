Handlebars.registerHelper 'select', (value, options) ->
  $el = $("<select />").html( options.fn(@) )
  $el.find("[value='#{value}']").attr({'selected':'selected'})
  $el.html()
