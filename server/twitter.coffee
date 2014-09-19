TwitterBinding = (key, secret) ->
  return new oauth.OAuth(
    'https://api.twitter.com/oauth/request_token',
    'https://api.twitter.com/oauth/access_token',
    key,
    secret,
    '1.0A',
    null,
    'HMAC-SHA1'
  )

@getTwitter = (creds, username) ->
  binding = TwitterBinding(Meteor.settings.twitter.key, Meteor.settings.twitter.secret)

  data = wrappedGet(binding, "https://api.twitter.com/1.1/users/lookup.json?screen_name=#{username}", creds)

  # TODO: handle error
  return JSON.parse(data)[0]

@startTwitterTimer = (creds) ->
  insertTwitter = ->
    data = getTwitter(creds, "SandstormIO")
    data.timestamp = new Date()
    TwitterData.insert(data)

  Meteor.setInterval(insertTwitter, 300000)
  insertTwitter()
