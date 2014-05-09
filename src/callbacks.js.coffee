Fishpond::loading = (callback) ->
  @callbacks ||= {}
  @callbacks['loading'] = callback

Fishpond::ready = (callback) ->
  @callbacks ||= {}
  @callbacks['ready'] = callback

Fishpond::error = (callback) ->
  @callbacks ||= {}
  @callbacks['error'] = callback

Fishpond::resultsUpdated = (callback) ->
  @callbacks ||= {}
  @callbacks['resultsUpdated'] = callback
