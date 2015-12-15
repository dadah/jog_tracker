class App.View extends Backbone.View

  initialize: ->
    @_bindLinks()

  _bindLinks: ->
    # HTML5 pushState links
    $(document).on 'click', 'a:not([data-bypass])', (evt) ->
      # Early bailout
      return if evt.isDefaultPrevented()
      return if evt.altKey or evt.ctrlKey or evt.metaKey

      href = $(@).attr('href')
      return unless href?

      if href is window.location.pathname
        evt.preventDefault()
        return

      protocol = "#{@.protocol}//"

      if @.hostname? and @.hostname isnt (window.location.hostname)
        window.location.href = href
        return

      unless href.slice(protocol.length) is protocol
        evt.preventDefault()
        Backbone.history.navigate href, {trigger: true}

_.extend App.View.prototype, App.Mixins
