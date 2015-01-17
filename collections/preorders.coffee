@Preorders = new Meteor.Collection 'preorders'

if Meteor.isServer
  Preorders._ensureIndex( {timestamp: 1} )
