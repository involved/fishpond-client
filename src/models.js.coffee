class Fishpond::Pond
  constructor: (@fishpond) ->

  build: (api_response) ->
    @id = api_response.id
    @name = api_response.name
    @fish_count = api_response.fish_count
    @tags = api_response.tags
    @filters = (filter for filter in api_response.filters when filter.category == null)
    @categorized_filters = (filter for filter in api_response.filters when filter.category)
    @tag_ids = { community:'community' }
    @filter_ids = {}
    @categorized_filters_by_category = {}
    @fish = []

    for tag in @tags
      @tag_ids[tag.slug] = tag.id

    for filter in @filters
      @filter_ids[filter.slug] = filter.id

    for filter in @categorized_filters
      @filter_ids[filter.slug] = filter.id
      if !@categorized_filters_by_category[filter.category]
        @categorized_filters_by_category[filter.category] = []
      @categorized_filters_by_category[filter.category].push(filter)

  toString: ->
    @name

  load_all_fish: (complete) ->
    @fishpond.debug("Loading #{this.fish_count} fish")
    this.load_fish(1, complete)

  find_fish: (fish_id) ->
    for f in @fish
      return f if f.id == fish_id
    return undefined

  default_query_tags: ->
    default_tags = {}
    for tag in this.tags
      default_tags[tag.id] = 10
    default_tags

  slugged_tag_name: (id) ->
    for tag in @tags
      if tag.id == id
        return tag.slug

  humanized_tag_name: (id) ->
    for tag in @tags
      if tag.id == id
        return tag.name

  default_query_filters: ->
    default_filters = {}
    for filter in this.filters.concat(this.categorized_filters)
      default_filters[filter.id] = false
    default_filters

  slugged_filter_name: (id) ->
    for filter in @filters
      if filter.id == id
        return filter.slug

  humanized_filter_name: (id) ->
    for filter in @filters
      if filter.id == id
        return filter.name

  is_filter: (id) ->
    for filter in @filters
      if filter.id == id
        return true
    false

  is_tag: (id) ->
    for tag in @tags
      if tag.id == id
        return true
    false

  get_tag_by_name: (name) ->
    for tag in @tags
      if tag.name == name
        return tag
    false

  get_tag: (id) ->
    for tag in @tags
      if tag.id == id
        return tag
    false

  get_filter: (id) ->
    for filter in @filters
      if filter.id == id
        return filter

    for filter in @categorized_filters
      if filter.id == id
        return filter

    false

  load_fish: (page, complete) ->
    _pond = this
    _fishpond = @fishpond

    handler = (response) ->
      for fish_response in response
        fish = new Fishpond::Fish(_pond)
        fish.build(fish_response)
        _pond.fish.push fish

      _fishpond.trigger('loading', (_pond.fish.length/_pond.fish_count))
      _fishpond.debug("Loaded #{_pond.fish.length}/#{_pond.fish_count}")
      if response.length > 0
        _pond.load_fish(page + 1, complete)
      else
        complete()

    _fishpond.connection.request ['ponds', @id, "fish"], handler, {page: page}


class Fishpond::Fish
  constructor: (@pond) ->

  build: (api_response) ->
    @id = api_response.id
    @title = api_response.title
    @tags = api_response.tags
    @community_tags = api_response.community_tags
    @humanized_tags = []
    @humanized_filters = []
    @is_cached = false
    @up_voted = false
    @metadata = {}
    this.humanize_tags()
    this.ingest_metadata(api_response)

  # Checks for the presence of metadata in a given object and caches it
  #
  # @param [Object] data the data, usually from an API response
  #
  ingest_metadata: (data) ->
    reserved_fields = ['id', 'title', 'tags', 'community_tags']
    for field, value of data
      if reserved_fields.indexOf(field) == -1
        @metadata[field] = value
        @is_cached = true

  humanize_tags: ->
    for tag_id, value of @tags
      if this.pond.is_tag(tag_id)
        @humanized_tags.push({name:this.pond.humanized_tag_name(tag_id), slug:this.pond.slugged_tag_name(tag_id), token:tag_id, value:parseInt(value, 10)})

      if this.pond.is_filter(tag_id)
        @humanized_filters.push({name:this.pond.humanized_filter_name(tag_id), slug:this.pond.slugged_filter_name(tag_id), token:tag_id, value:Boolean(parseInt(value, 10))})

  matches_filters: (query_filters) ->
    filtered = true
    filter_groups = []
    query_groups = []

    for filter_id, value of query_filters
      query_groups.push(this.pond.get_filter(filter_id).group) if Boolean(parseInt(value, 10))

    for filter_index, filter of this.pond.filters.concat(this.pond.categorized_filters)
      if filter && query_filters[filter.id]
        filter_groups.push(filter.group) if Boolean(parseInt(this.tags[filter.id], 10)) && Boolean(parseInt(query_filters[filter.id], 10))

    query_groups = Fishpond::array_unique(query_groups)
    filter_groups = Fishpond::array_unique(filter_groups)
    return false if query_groups.count == 0

    Fishpond::arrays_equal(query_groups, filter_groups)

  popularity: ->
    this.tags['popularity']

  calculate_score: (query_tags) ->
    score = 0
    community_ratio = this.community_ratio(query_tags)
    for tag_id, value of query_tags
      score += this.calculate_tag_score(tag_id, value, community_ratio)
    Math.round(score)

  calculate_tag_score: (tag_id, value, community_ratio) ->
    value = parseInt(value, 10)
    if value is false || this.tags[tag_id] is undefined
      0
    else
      if this.community_tags[tag_id] is undefined
        difference = this.tags[tag_id] - value
      else
        difference = community_ratio*this.community_tags[tag_id] +
                     (1-community_ratio)*this.tags[tag_id] - value
      difference * difference

  community_ratio: (query_tags) ->
    community_tag_value = parseInt(query_tags['community'], 10)
    if community_tag_value is undefined
      0
    else
      community_tag_value / 20.0

  add_community_tags: (community_humanized_tags, callback) ->
    community_tags = {}
    _fish = this
    handler = (response) ->
      callback()

    for tag_slug, value of community_humanized_tags
      tag_id = _fish.pond.tag_ids[tag_slug]
      community_tags[tag_id] = parseInt(value, 10)

    @pond.fishpond.connection.request ['ponds', @pond.id, 'fish', this.id, 'feedbacks'], handler, { community_feedback: community_tags }

  up_vote: ->
    _fish = this
    @pond.fishpond.connection.request ['ponds', @pond.id, 'fish', this.id, 'up_vote'], (response) ->
      _fish.up_voted = true

  get_metadata: (callback) ->
    if @is_cached
      callback(this)
    else
      _fish = this
      @pond.fishpond.connection.request ['ponds', @pond.id, 'fish', this.id], (response) ->
        _fish.ingest_metadata(response)
        callback(_fish)

class Fishpond::Result
  constructor: ->
    @score = undefined
    @fish = undefined
