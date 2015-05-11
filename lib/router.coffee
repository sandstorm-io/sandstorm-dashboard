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
  @route "uploadLog",
    where: "server"
    path: "/uploadLog/:tokenId"
    action: ->
      tokenId = @params.tokenId

      if tokenId != Meteor.settings.logToken
        @response.writeHead 403,
          "Content-Type": "text/plain"

        @response.write "Wrong token"
        @response.end()
        return

      if @request.method != "POST"
        @response.writeHead 405,
          "Content-Type": "text/plain"

        @response.write "You can only POST here."
        @response.end()
        return

      try
        Meteor.bindEnvironment(doLogUpload(@request))
        @response.writeHead 200,
          "Content-Type": "text/plain"

        @response.end()
      catch error
        console.error error.stack
        @response.writeHead 500,
          "Content-Type": "text/plain"

        @response.write error.stack
        @response.end()

      return
  @route "uploadSandcats",
    where: "server"
    path: "/uploadSandcats/:tokenId"
    action: ->
      tokenId = @params.tokenId

      if tokenId != Meteor.settings.sandcatsToken
        @response.writeHead 403,
          "Content-Type": "text/plain"

        @response.write "Wrong token"
        @response.end()
        return

      if @request.method != "POST"
        @response.writeHead 405,
          "Content-Type": "text/plain"

        @response.write "You can only POST here."
        @response.end()
        return

      try
        Meteor.bindEnvironment(doSandcatsUpload(@request))
        @response.writeHead 200,
          "Content-Type": "text/plain"

        @response.end()
      catch error
        console.error error.stack
        @response.writeHead 500,
          "Content-Type": "text/plain"

        @response.write error.stack
        @response.end()

      return

@userIsAdmin = (user) ->
  try
    user.services.google.email.split('@').slice(-1)[0] == Meteor.settings.public.domain
  catch error
    return false

requireAdmin = (pause) ->
  if Meteor.user()
    if userIsAdmin(Meteor.user())
      @next()
      return
    else
      @render "accessDenied"
  else
    if Meteor.loggingIn()
      @render @loadingTemplate
    else
      @render "accessDenied"
  pause()

nonMeteorRoutes = ['uploadLog', 'uploadSandcats']

Router.onBeforeAction "loading", {except: nonMeteorRoutes}
Router.onBeforeAction requireAdmin, {except: nonMeteorRoutes}
Router.onBeforeAction( ->
  clearErrors()
  @next()
, {except: nonMeteorRoutes})

