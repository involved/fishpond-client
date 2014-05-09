Fishpond::track = (category, action, label, value) ->
  if this.event_tracking_enabled
    this.log "Tracking: #{category} | #{action} | #{label} | #{value}"
    _gaq.push(['_trackEvent', category, action, label, value])
