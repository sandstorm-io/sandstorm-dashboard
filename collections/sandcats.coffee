@Sandcats = new Meteor.Collection 'sandcats'

if Meteor.isServer
  Sandcats._ensureIndex( {timestamp: 1} )
