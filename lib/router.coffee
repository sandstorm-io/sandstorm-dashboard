if Meteor.isClient
  Meteor.subscribe 'userData'

Router.configure
  layoutTemplate: "layout"
  loadingTemplate: "loading"

Router.map ->
  @route "home",
    path: "/"
    waitOn: ->
      return Meteor.subscribe('userDashboard')
    data: ->
      return Dashboards.findOne()
  @route "setup",
    path: "/setup"
    data: ->
      return Meteor.user()

requireAdmin = (pause) ->
  if Meteor.user()
    if _.contains(Meteor.user().permissions, 'admin')
      return
    else
      @render "accessDenied"
  else
    if Meteor.loggingIn()
      @render @loadingTemplate
    else
      @render "accessDenied"
  pause()

Router.onBeforeAction "loading"
Router.onBeforeAction requireAdmin
Router.onBeforeAction ->
  clearErrors()
