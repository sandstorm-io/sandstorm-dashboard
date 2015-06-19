@OasisSandstormData = new Meteor.Collection 'oasisSandstormData'

if Meteor.isServer
  OasisSandstormData._ensureIndex( {timestamp: 1} )
