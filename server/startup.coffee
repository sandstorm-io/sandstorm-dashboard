Meteor.startup ->
  twitter = Accounts.loginServiceConfiguration.findOne {service: "twitter"}
  if not twitter
    Accounts.loginServiceConfiguration.insert
      service: "twitter"
      consumerKey: Meteor.settings.twitter.key
      secret: Meteor.settings.twitter.secret

  if Meteor.users.find().count() < 1
    user = Accounts.createUser
      username    : 'admin',
      email       : 'admin@jparyani.com'

    Accounts.sendEnrollmentEmail user
    user = Meteor.users.findOne()
    Meteor.users.update({_id: user._id}, {'$set': {permissions: ['admin']}})
