zip = (arrays) ->
  arrays[0].map (_, i) ->
    arrays.map (array) ->
      array[i]

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
    graph = Flotr.draw myTextElement[0], [ zip([data.x_axis, data.y_axis]) ],
      xaxis:
        mode: if currentSettings.x_axis.indexOf('time') != -1 then 'time' else 'normal'
        timeMode: 'local'
        tickDecimals: 0
      yaxis:
        tickDecimals: 0
      grid:
        verticalLines: false
        horizontalLines: false
      mouse:
        track: true
        trackAll: true

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
        ]
      }
    ]
    newInstance: (settings, newInstanceCallback) ->
      newInstanceCallback new myWidgetPlugin(settings)
      return
