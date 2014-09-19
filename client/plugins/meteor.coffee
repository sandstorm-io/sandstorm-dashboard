meteorPlugin = (settings, updateCallback) ->
  # This is some function where I'll get my data from somewhere
  getData = ->
    source = currentSettings.source_name
    source = source.charAt(0).toUpperCase() + source.slice(1);
    Meteor.call "fetch#{source}", (err, data) ->
      if err
        console.log err
      else
        updateCallback data

    return
  createRefreshTimer = (interval) ->
    interval = interval * 1000
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

  createRefreshTimer currentSettings.refresh_time
  return

@loadMeteorPlugin = ->
  freeboard.loadDatasourcePlugin
    type_name: "meteor_plugin"
    display_name: "Meteor Data"
    description: "This is a data source for meteor collections"
    settings: [
      {
        name: "source_name"
        display_name: "Source Name"
        type: "text"
        description: "The name of the data source to use. Must be twitter|mailchimp|google|github"
        default_value: 'twitter'
      }
      {
        name: "refresh_time"
        display_name: "Refresh Time"
        type: "text"
        description: "In seconds"
        default_value: 300
      }
    ]
    newInstance: (settings, newInstanceCallback, updateCallback) ->
      newInstanceCallback new meteorPlugin(settings, updateCallback)
      return

