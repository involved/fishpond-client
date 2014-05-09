Fishpond::get_fish = (fish_id, callback) ->
  _fishpond = this
  _fishpond.debug("Sending metadata request for fish #{fish_id}")
  fish = @pond.find_fish(fish_id)
  fish.get_metadata (fish) ->
    callback(fish)
