# check that the userId specified owns the documents
# TODO: add permissions
@ownsDocument = (userId, doc) ->
  return true
  doc and doc.userId is userId

@isAdmin = (userId) ->
  return true
  user = Meteor.users.findOne userId
  user and _.contains(user.permissions, 'admin')
