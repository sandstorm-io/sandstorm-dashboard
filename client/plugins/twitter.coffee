twitterPlugin = (settings, updateCallback) ->
  # This is some function where I'll get my data from somewhere
  getData = ->
    Meteor.call 'fetchTwitter', (err, data) ->
      if err
        console.log err
      else
        updateCallback data

    return
  createRefreshTimer = (interval) ->
    clearInterval refreshTimer  if refreshTimer
    refreshTimer = setInterval(->
      getData()
      return
    , interval)
    return
  self = this
  currentSettings = settings
  refreshTimer = undefined
  self.onSettingsChanged = (newSettings) ->
    clearInterval refreshTimer
    currentSettings = newSettings
    createRefreshTimer currentSettings.refresh_time
    return

  self.updateNow = ->
    getData()
    return

  self.onDispose = ->
    clearInterval refreshTimer
    refreshTimer = `undefined`
    return

  Meteor.setTimeout(->
    current_time = currentSettings.past_time
    while current_time > 0
      self.updateNow()
      current_time -= currentSettings.refresh_time
  , 3000)

  createRefreshTimer currentSettings.refresh_time
  return

@loadTwitterPlugin = ->
  freeboard.loadDatasourcePlugin
    type_name: "twitter_plugin"
    display_name: "Twitter"
    description: "This is a data source for twitter data"
    settings: [
      {
        name: "refresh_time"
        display_name: "Refresh Time"
        type: "text"
        description: "In milliseconds"
        default_value: 5000
      }
    ]
    newInstance: (settings, newInstanceCallback, updateCallback) ->
      newInstanceCallback new twitterPlugin(settings, updateCallback)
      return

