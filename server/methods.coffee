Future = Npm.require('fibers/future')

isNumber = (n) ->
  return !isNaN(parseFloat(n)) && isFinite(n)

# Meteor._wrapAsync fails for some reason
@wrappedGet = (binding, url, creds) ->
  fut = new Future()
  binding.get url, creds.accessToken, creds.accessTokenSecret, (err, data) ->
    if err
      fut.throw err
    else
      fut.return data

  return fut.wait()

fetch = (collection, start, end, resample, sum, delta, options) ->
  res = []
  nextTimestamp = 0
  options = options || {}

  if (not options.sort)
    options.sort = {timestamp: 1}

  res = collection.find({}, options).fetch()

  if res.length
    newData = {}
    keys = Object.keys(res[0])
    for key in keys
      newData[key] = []

    for row in res
      for key in keys
        newData[key].push row[key]

    if collection == LogData or collection == SandstormData or collection == DemoSandstormData
      newData['timestamp'] = _.map newData['timestamp'], (val) ->
        return new Date(val)

    if sum
      for key in keys
        first = newData[key][0]
        if +first == first or key == 'ga:sessions' or key == 'ga:hits'
          total = 0
          newData[key] = _.map newData[key], (val) ->
            total += +val
            return total

      newData["_count"] = _.range(1, res.length + 1)
      if collection == LogData
        total = 0
        newData["count_daily"] = _.map newData['type'], (val) ->
          if val == 'daily'
            total += 1
          return total
        total = 0
        newData["count_install"] = _.map newData['type'], (val) ->
          if val == 'install'
            total += 1
          return total
        total = 0
        newData["count_startup"] = _.map newData['type'], (val) ->
          if val == 'startup'
            total += 1
          return total
        total = 0
        newData["count_manual"] = _.map newData['type'], (val) ->
          if val == 'manual'
            total += 1
          return total
        total = 0
        newData["count_retry"] = _.map newData['type'], (val) ->
          if val == 'retry'
            total += 1
          return total

    res = newData

    if resample
      if not start
        start = res.timestamp[0]
      if not end
        end = res.timestamp[res.timestamp.length - 1]

      newData = {}
      keys = Object.keys res
      for key in keys
        newData[key] = []

      start = +start
      end = +end
      currT = start
      i = 0
      previous = 0
      while currT < end and i < res.timestamp.length
        currT += 86400000
        while res.timestamp[i] < currT
          if i == res.timestamp.length - 1
            break
          i += 1

        if delta
          for key in keys
            newData[key].push(res[key][i] - res[key][previous])
        else
          for key in keys
            newData[key].push(res[key][i])

        newData.timestamp[newData.timestamp.length - 1] = new Date(currT)
        previous = i
      res = newData

  return res

fetchLatest = (collection) ->
  return collection.findOne({}, {sort: {$natural: -1 }, limit: 1})

Meteor.methods
  updateDashboard: (data) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    data.userId = "main"
    Dashboards.upsert({userId: "main"}, data)

  setupTwitter: (credentialToken, credentialSecret) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    data = OauthRetrieveCredential(credentialToken, credentialSecret)
    options = data.serviceData
    Meteor.users.update {_id: Meteor.userId()}, {'$set': {'profile.isTwitterSetup': true, 'services.twitter': options}}
    startTwitterTimer(options)

  fetchLatestTwitter: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(TwitterData)

  fetchLatestMailchimp: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(MailchimpData)

  fetchLatestGoogle: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(GoogleData)

  fetchLatestGithub: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(GithubData)

  fetchLatestLog: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(LogData)

  fetchLatestPreorders: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetchLatest(Preorders)

  fetchTwitter: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(TwitterData, start, end, true, false, false, {fields: {timestamp: 1, followers_count: 1, statuses_count: 1}})

  fetchMailchimp: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(MailchimpData, start, end, true, false, false, {fields: {timestamp: 1, stats_member_count: 1}})

  fetchGoogle: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(GoogleData, start, end, true, true, true, {fields: {timestamp: 1, 'ga:hits': 1, 'ga:sessions': 1}})

  fetchGithub: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(GithubData, start, end, true, false, false, {fields: {timestamp: 1, stargazers_count: 1, subscribers_count: 1}})

  fetchSandstorm: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(SandstormData, start, end, false, false, false)

  fetchDemoSandstorm: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(DemoSandstormData, start, end, false, false, false)

  fetchLog: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(LogData, start, end, true, true, true, {fields: {timestamp: 1, type: 1}})

  fetchPreorders: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return fetch(Preorders, start, end, true, false, false)
