# Wrapper for console.log
# When the 'quiet' option is given to Fishpond, output is supressed. It
# also checks for browser logging, to aid compatibility with older IEs
Fishpond::log = (msg) ->
  this.raw_log "[Fishpond] #{msg}"

Fishpond::debug = (msg) ->
  if @options['debug'] == true
    this.log(msg)

# Logs without [Fishpond] prefix - good for logging objects.
Fishpond::raw_log = (msg) ->
  unless @options['quiet'] == true
    if console && console.log
      console.log msg

# tests content, not order
Fishpond::arrays_equal = (a, b) ->
  a.length is b.length and a.every (elem, i) -> b.indexOf(elem) != -1

Fishpond::array_unique = (a) ->
  output = {}
  output[a[key]] = a[key] for key in [0...a.length]
  value for key, value of output
