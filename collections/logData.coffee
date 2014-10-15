@LogData = new Meteor.Collection 'logData'

if Meteor.isServer
  LogData._ensureIndex( {timestamp: 1} )
