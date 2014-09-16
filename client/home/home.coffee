Template.home.rendered = ->
   head.js "js/freeboard+plugins.min.js", =>
    $ =>
      freeboard.loadDatasourcePlugin
        type_name: "my_datasource_plugin"
        display_name: "Datasource Plugin Example"
        description: "Some sort of description <strong>with optional html!</strong>"
        settings: [
          {
            name: "first_name"
            display_name: "First Name"
            type: "text"
            default_value: "John"
            description: "This is pretty self explanatory..."
          }
          {
            name: "last_name"
            display_name: "Last Name"
            type: "calculated"
          }
          {
            name: "is_human"
            display_name: "I am human"
            type: "boolean"
          }
          {
            name: "age"
            display_name: "Your age"
            type: "option"
            options: [
              {
                name: "0-50"
                value: "young"
              }
              {
                name: "51-100"
                value: "old"
              }
            ]
          }
          {
            name: "other"
            display_name: "Other attributes"
            type: "array"
            settings: [
              {
                name: "name"
                display_name: "Name"
                type: "text"
              }
              {
                name: "value"
                display_name: "Value"
                type: "text"
              }
            ]
          }
          {
            name: "refresh_time"
            display_name: "Refresh Time"
            type: "text"
            description: "In milliseconds"
            default_value: 5000
          }
        ]
        newInstance: (settings, newInstanceCallback, updateCallback) ->
          newInstanceCallback new myDatasourcePlugin(settings, updateCallback)
          return

      freeboard.loadWidgetPlugin
        type_name: "my_widget_plugin"
        display_name: "Widget Plugin Example"
        description: "Some sort of description <strong>with optional html!</strong>"
        external_scripts: [
          "http://mydomain.com/myscript1.js"
          "http://mydomain.com/myscript2.js"
        ]
        fill_size: false
        settings: [
          {
            name: "the_text"
            display_name: "Some Text"
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
                name: "Big"
                value: "big"
              }
            ]
          }
        ]
        newInstance: (settings, newInstanceCallback) ->
          newInstanceCallback new myWidgetPlugin(settings)
          return
      freeboard.initialize true, =>
        theFreeboardModel.loadDashboard(@data)

updateDashboard = ->
  Meteor.call 'updateDashboard', theFreeboardModel.serialize(), (err) ->
    if err
      console.log err

Template.home.events
  'click #saveDashboard': ->
    updateDashboard()

Meteor.setInterval updateDashboard, 30000
