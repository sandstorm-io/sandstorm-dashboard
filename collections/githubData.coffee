@GithubData = new Meteor.Collection 'githubData'

if Meteor.isServer
  GithubData._ensureIndex( {timestamp: 1} )
