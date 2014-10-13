@SandstormData = new Meteor.Collection 'sandstormData'

if Meteor.isServer
  SandstormData._ensureIndex( {timestamp: 1} )
