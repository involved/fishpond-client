root = exports ? this

class root.Fishpond
  constructor: (@api_key, @options = {}) ->
    @created_at = new Date()
    @_ready = false
    this.log "Creating fishpond instance"
    @connection = new Fishpond::Connection(this)

    # Default event handlers
    _fishpond = this
    this.loading (percent_complete) ->
      _fishpond.log "Loading #{percent_complete * 100}%"

    this.ready (pond) ->
      _fishpond.log "Ready to query '#{pond}'"

    this.error (msg) ->
      _fishpond.log "Error"
      _fishpond.log msg

    this.resultsUpdated (results) ->
      _fishpond.log "Results updated"
      _fishpond.raw_log results

  init: (@pond_id) ->
    _fishpond = this
    this.log "Init with pond #{@pond_id}"
    _fishpond.trigger('loading', 0.0)
    @connection.request ['ponds', @pond_id], (response) ->
      _fishpond.pond = new Fishpond::Pond(_fishpond)
      _fishpond.pond.build(response)
      _fishpond.debug "Loaded pond '#{_fishpond.pond}'"
      _fishpond.pond.load_all_fish ->
        _fishpond.trigger('loading', 1.0)
        @_ready = true
        _fishpond.log("Ready");
        _fishpond.trigger('ready', _fishpond.pond)

  trigger: (callback, args...) ->
    @callbacks[callback](args[0])

  time_alive: ->
    return parseInt((new Date - this.created_at)/1000, 10)

  # UA-34152191-1
  enable_event_tracking: (ga_id, domain) ->
    @event_tracking_enabled = true
    _gaq = _gaq || []
    _gaq.push(['_setAccount', ga_id])
    _gaq.push(['_setDomainName', domain])
    _gaq.push(['_setAllowLinker', true])
    _gaq.push(['_trackPageview'])
    ga = document.createElement('script')
    ga.type = 'text/javascript'
    ga.async = true
    subdomain = 'http://www'
    if 'https:' == document.location.protocol
      subdomain = 'https://ssl'
    ga.src = "#{subdomain}.google-analytics.com/ga.js"
    s = document.getElementsByTagName('script')[0]
    s.parentNode.insertBefore(ga, s)
    this.log "Event tracking enabled with ID #{ga_id} on #{domain}"
