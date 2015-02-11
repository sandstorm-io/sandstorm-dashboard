Template.home.rendered = ->
   head.js "js/freeboard+plugins.min.js", =>
    $ =>
      loadMeteorPlugin()
      loadGraphWidget()

      freeboard.initialize false, =>
        theFreeboardModel.loadDashboard(@data)

updateDashboard = ->
  Meteor.call 'updateDashboard', theFreeboardModel.serialize(), (err) ->
    if err
      console.log err

Template.home.events
  'click #saveDashboard': ->
    updateDashboard()

# Meteor.setInterval updateDashboard, 5000
