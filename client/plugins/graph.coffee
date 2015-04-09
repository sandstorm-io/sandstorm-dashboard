zip = (arrays) ->
  arrays[0].map (_, i) ->
    arrays.map (array) ->
      array[i]

findBounds = (array) ->
  min = array[0]
  max = array[0]

  for elem in array
    if elem < min
      min = elem
    if elem > max
      max = elem

  return {
    min: min
    max: max
  }

myWidgetPlugin = (settings) ->
  self = this
  currentSettings = settings
  myTextElement = $("<div class='graph'></div>")
  graph = null
  data = {}
  self.render = (containerElement) ->
    $(containerElement).append myTextElement
    return

  self.getHeight = ->
    if currentSettings.size is "xxl"
      8
    if currentSettings.size is "xl"
      4
    else if currentSettings.size is "big"
      2
    else
      1

  self.onSettingsChanged = (newSettings) ->
    currentSettings = newSettings
    return

  drawGraph = ->
    yaxis =
      tickDecimals: 0
    trackformatter = Flotr.defaultTrackFormatter
    if currentSettings.y_logarithmic
      base = 10
      baseLog = Math.log base
      yaxis.tickDecimals = 10
      yaxis.scaling = 'logarithmic'
      bounds = findBounds(data.y_axis)
      val = 1
      yaxis.ticks = while val < bounds.max
        val *= 10
        [Math.log(val) / baseLog, val]
      yaxis.ticks.push([(Math.log(bounds.min) / baseLog) || 0, bounds.min])
      yaxis.ticks.push([Math.log(bounds.max) / baseLog, bounds.max])
      data_y_axis = data.y_axis.map (elem) ->
        Math.log(elem) / baseLog
      zipped_data = [ zip([data.x_axis, data_y_axis]) ]
      trackformatter = (obj) ->
        "(#{obj.x.toString()}, #{data.y_axis[obj.index]})"
    else
      zipped_data = [ zip([data.x_axis, data.y_axis]) ]
    graph = Flotr.draw myTextElement[0], zipped_data,
      xaxis:
        mode: if currentSettings.x_axis.indexOf('time') != -1 then 'time' else 'normal'
        timeMode: 'local'
        tickDecimals: 0
      yaxis: yaxis
      grid:
        verticalLines: false
        horizontalLines: false
      mouse:
        track: true
        trackAll: true
        trackFormatter: trackformatter

  self.onCalculatedValueChanged = (settingName, newValue) ->
    data[settingName] = newValue

    if data.x_axis and data.y_axis
      setTimeout drawGraph, 500
    return

  self.onDispose = ->
    return

  return

@loadGraphWidget = ->
  freeboard.loadWidgetPlugin
    type_name: "my_widget_plugin"
    display_name: "Graph"
    description: "Graphing widget"
    fill_size: false
    settings: [
      {
        name: "x_axis"
        display_name: "X Axis"
        type: "calculated"
      }
      {
        name: "y_axis"
        display_name: "Y Axis"
        type: "calculated"
      }
      {
        name: "y_logarithmic"
        display_name: "Scale Y Axis Logarithmically"
        type: "boolean"
      }
      {
        name: "size"
        display_name: "Size"
        type: "option"
        options: [
          {
            name: "Regular"
            value: "regular"
          }
          {
            name: "Large"
            value: "big"
          }
          {
            name: "Extra Large"
            value: "xl"
          }
          {
            name: "Extra Extra Large"
            value: "xxl"
          }
        ]
      }
    ]
    newInstance: (settings, newInstanceCallback) ->
      newInstanceCallback new myWidgetPlugin(settings)
      return
