Future = Npm.require('fibers/future')

# Meteor._wrapAsync fails for some reason
@wrappedGet = (binding, url, creds) ->
  fut = new Future()
  binding.get url, creds.accessToken, creds.accessTokenSecret, (err, data) ->
    if err
      fut.throw err
    else
      fut.return data

  return fut.wait()

fetch = (collection, start, end) ->
  data = collection.find().fetch()
  # TODO: filter
  # TODO: resample based on timestamp

  if data.length
    newData = {}
    for key in data[0]
      newData[key] = []

    for row in data
      for key in newData
        row[key].push row[key]

    data = newData

  return data

fetchLatest = (collection) ->
  return collection.findOne({}, {sort: {$natural: -1 }, limit: 1})

Meteor.methods
  updateDashboard: (data) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    data.userId = Meteor.userId()
    Dashboards.upsert({userId: Meteor.userId()}, data)

  setupTwitter: (credentialToken, credentialSecret) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    data = OauthRetrieveCredential(credentialToken, credentialSecret)
    options = data.serviceData
    Meteor.users.update {_id: Meteor.userId()}, {'$set': {'profile.isTwitterSetup': true, 'services.twitter': options}}
    startTwitterTimer(options)

  fetchLatestTwitter: ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(TwitterData)

  fetchLatestMailchimp: ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(MailchimpData)

  fetchLatestGoogle: ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(GoogleData)

  fetchLatestGithub: ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(GithubData)

  fetchTwitter: (start, end) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(TwitterData, start, end)

  fetchMailchimp: (start, end) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(MailchimpData, start, end)

  fetchGoogle: (start, end) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(GoogleData, start, end)

  fetchGithub: (start, end) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(GithubData, start, end)
