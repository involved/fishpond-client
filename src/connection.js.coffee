#= require jsonp

class Fishpond::Connection
  constructor: (@fishpond) ->
    @fishpond.debug("Connection created")
    @api_endpoint = "http://www.ifish.io/api"
    @request_queue = []
    @current_requests = 0
    @max_simultaneous_requests = 2

    if @fishpond.options['development']
      @fishpond.debug "Development connection selected"
      @api_endpoint = "http://#{window.location.host}/api"

    if @fishpond.options['api_endpoint']
      @api_endpoint = fishpond.options['api_endpoint']

    @fishpond.debug "Using API endpoint #{@api_endpoint}"

  api_resource_url: (resource) ->
    [@api_endpoint, resource].join("/")

  request: (resource_pieces, callback, data) ->
    this.send_request(resource_pieces.join("/"), callback, data)

  parameterize_data: (params) ->
    pairs = []
    do proc = (object=params, parent_prefix=null) ->
      for own key, value of object
        prefix = parent_prefix
        if value instanceof Array
          for el, i in value
            proc(el, if prefix? then "#{prefix}[#{key}][]" else "#{key}[]")
        else if value instanceof Object
          if prefix?
            prefix += "[#{key}]"
          else
            prefix = key
          proc(value, prefix)
        else
          pairs.push(if prefix? then "#{prefix}[#{key}]=#{value}" else "#{key}=#{value}")
    pairs.join('&')

  process_request: (resource, callback, post_data) ->
    @fishpond.debug("Requesting #{resource}")

    url = this.api_resource_url(resource)
    _fishpond = @fishpond
    _connection = this

    data = post_data
    if !data
      data = {}
    data.v = "1"
    data.k = _fishpond.api_key

    if @fishpond.options['include_metadata']
      data.m = "1"

    parameter_string = this.parameterize_data(data)
    full_request_url = "#{url}?#{parameter_string}"

    this.connect full_request_url, {}, (response) ->
      _fishpond.debug("Success");
      _fishpond.debug(response)
      _connection.current_requests -= 1
      callback(response)
      _connection.check_queue_and_process_next()

  check_queue_and_process_next: ->
    if(@current_requests < @max_simultaneous_requests && @request_queue.length > 0)
      @current_requests += 1
      first_queue_item = @request_queue.shift()
      this.process_request(first_queue_item['resource'], first_queue_item['callback'], first_queue_item['data'])

  send_request: (resource, callback, data) ->
    @request_queue.push({resource: resource, callback: callback, data: data})
    this.check_queue_and_process_next()

  connect: JSONP.get
