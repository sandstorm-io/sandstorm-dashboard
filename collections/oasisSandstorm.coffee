@OasisSandstormData = new Meteor.Collection 'oasisSandstormData'
@OasisMonitorData = new Meteor.Collection 'oasisMonitorData'

if Meteor.isServer
  OasisSandstormData._ensureIndex( {timestamp: 1} )
  OasisMonitorData._ensureIndex( {timestamp: 1, number: 1} )
