# TODO: add authorization
Meteor.publish 'userDashboard', ->
  return Dashboards.find {userId: @userId}

Meteor.publish 'userData', ->
  if @userId
    return Meteor.users.find({_id: @userId},
                             {fields: {'permissions': 1}});
  else
    @ready()

