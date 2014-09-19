@GoogleData = new Meteor.Collection 'googleData'

if Meteor.isServer
  GoogleData._ensureIndex( {timestamp: 1} )
