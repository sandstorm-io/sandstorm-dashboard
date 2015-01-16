@DemoSandstormData = new Meteor.Collection 'demoSandstormData'

if Meteor.isServer
  DemoSandstormData._ensureIndex( {timestamp: 1} )
