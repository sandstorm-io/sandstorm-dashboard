Meteor.publish 'userDashboard', ->
  return Dashboards.find {userId: "main"}

Meteor.publish 'userData', ->
  if @userId
    return Meteor.users.find({_id: @userId},
                             {fields: {'services.google.email': 1, 'services.google.verified_email': 1}});
  else
    @ready()

