@myDatasourcePlugin = (settings, updateCallback) ->

  # This is some function where I'll get my data from somewhere
  getData = ->
    newData = hello: "world! it's " + new Date().toLocaleTimeString() # Just putting some sample data in for fun.

    # Get my data from somewhere and populate newData with it... Probably a JSON API or something.

    # ...
    updateCallback newData
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
    currentSettings = newSettings
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

@myWidgetPlugin = (settings) ->
  self = this
  currentSettings = settings
  myTextElement = $("<span></span>")
  self.render = (containerElement) ->
    $(containerElement).append myTextElement
    return

  self.getHeight = ->
    if currentSettings.size is "big"
      2
    else
      1

  self.onSettingsChanged = (newSettings) ->
    currentSettings = newSettings
    return

  self.onCalculatedValueChanged = (settingName, newValue) ->
    $(myTextElement).html newValue  if settingName is "the_text"
    return

  self.onDispose = ->
    return
