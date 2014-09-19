@MailchimpData = new Meteor.Collection 'mailchimpData'

if Meteor.isServer
  MailchimpData._ensureIndex( {timestamp: 1} )
