#= require string_score

# query
# tags - an object of key/value pairs of tag slugs and their query
# values (1 - 21)
# filters - an object of key/value pairs of filter slugs and their query
# values (true or false)

Fishpond::query = (query_tags, query_filters) ->
  this.debug "Querying #{@pond}"
  this.track(this.pond.name, "query", "tags:#{JSON.stringify(query_tags)}, filters:#{JSON.stringify(query_filters)}", this.time_alive())
  tags = @pond.default_query_tags()
  filters = @pond.default_query_filters()

  # convert tags
  for query_tag_slug, query_tag_value of query_tags
    tag_id = @pond.tag_ids[query_tag_slug]

    if tag_id != undefined
      if query_tag_value is false
        tags[tag_id] = false
      else
        tags[tag_id] = parseInt(query_tag_value)

  # convert filters
  for query_filter_slug, query_filter_value of query_filters
    filter_id = @pond.filter_ids[query_filter_slug]
    if filter_id != undefined
      filters[filter_id]= parseInt(query_filter_value)

  # score calculations
  results = []
  for fish in @pond.fish
    if fish.matches_filters(filters)
      result = new Fishpond::Result
      result.score = fish.calculate_score(tags)
      result.fish = fish
      results.push result

  # trigger callback with results
  results.sort (result1, result2) ->
    return 0 if result1.score == result2.score
    return 1 if result1.score > result2.score
    return -1 if result1.score < result2.score

  if this.event_tracking_enabled
    index = 1
    for result in results[0...30]
      this.track(result.fish.title, "ranked", "", index)
      index += 1

  this.trigger('resultsUpdated', results[0...30])
  true

# search
# string - a string to search for title similarity

Fishpond::search = (string) ->
  this.debug "Searching for titles like #{string} in #{@pond}"
  this.track(this.pond.name, "search", string, this.time_alive())

  results = []
  for fish in @pond.fish
    result = new Fishpond::Result
    result.score = fish.title.score(string)
    result.fish = fish
    if result.score > 0
      results.push result

  results.sort (result1, result2) ->
    return 0 if result1.score == result2.score
    return 1 if result1.score < result2.score
    return -1 if result1.score > result2.score

  results[0...5]
