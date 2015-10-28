@SandstormUserData = new Meteor.Collection 'sandstormUserData'

if Meteor.isServer
  SandstormUserData._ensureIndex( {timestamp: 1} )
