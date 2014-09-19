@TwitterData = new Meteor.Collection 'twitterData'

if Meteor.isServer
  TwitterData._ensureIndex( {timestamp: 1} )
