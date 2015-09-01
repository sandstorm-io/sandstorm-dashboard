url = Npm.require 'url'

Meteor.startup ->
  twitter = Accounts.loginServiceConfiguration.findOne {service: "twitter"}
  if not twitter
    Accounts.loginServiceConfiguration.insert
      service: "twitter"
      consumerKey: Meteor.settings.twitter.key
      secret: Meteor.settings.twitter.secret

  twitterUser = Meteor.users.findOne({'profile.isTwitterSetup': true})
  if twitterUser
    startTwitterTimer(twitterUser.services.twitter)

  startMailchimpTimer()
  startGithubTimer()
  startGoogleTimer()
  startSandstormTimer()
  startDemoSandstormTimer()
  startOasisSandstormTimer()
  startPreordersTimer()
  startOasisMonitorTimer()

  google_refresh = Meteor.settings.google.refresh
  console.log google_refresh
  if google_refresh
    refreshGoogle(google_refresh.start, google_refresh.end)

  Accounts.validateLoginAttempt (info) ->
    if !info.allowed
      return false
    user = info.user

    if !user.services?.google
      return false

    google = user.services.google

    if google.verified_email and userIsAdmin(user)
      return true
    throw new Meteor.Error(403, "You are not part of #{Meteor.settings.public.domain}")

