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

@fetch = (collection, start, end, resample, sum, delta, options) ->
  res = []
  nextTimestamp = 0
  options = options || {}

  if (not options.sort)
    options.sort = {timestamp: 1}

  filter = {}
  if options.filter?
    filter = options.filter
    delete options["filter"]

  res = collection.find(filter, options).fetch()

  if res.length
    newData = {}
    keys = Object.keys(res[0])

    if collection == OasisSandstormData
      keys.push("dailyActiveOverMonthlyActive")
      for row in res
        row.dailyActiveOverMonthlyActive = row.dailyActiveUsers / row.monthlyActiveUsers

    for key in keys
      newData[key] = []

    for row in res
      for key in keys
        newData[key].push row[key]

    if collection == LogData or collection == SandstormData or collection == DemoSandstormData or collection == OasisSandstormData or collection == SandstormUserData
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

# This is slighyly crazy, but all data sources follow an implicit naming schema.
# For example for twitter, there is a method named "fetchTwitter" that reads from the TwitterData
# collection, and writes to TwitterDataCache. This fact is used for simplifiying code.
@fetchMethods =
  fetchTwitter: (start, end) ->
    return fetch(TwitterData, start, end, true, false, false, {fields: {timestamp: 1, followers_count: 1, statuses_count: 1}})

  fetchMailchimp: (start, end) ->
    return fetch(MailchimpData, start, end, true, false, false, {fields: {timestamp: 1, stats_member_count: 1}})

  fetchGoogle: (start, end) ->
    return fetch(GoogleData, start, end, true, true, true, {fields: {timestamp: 1, 'ga:hits': 1, 'ga:sessions': 1}})

  fetchGithub: (start, end) ->
    return fetch(GithubData, start, end, true, false, false, {fields: {timestamp: 1, stargazers_count: 1, subscribers_count: 1}})

  fetchSandstorm: (start, end) ->
    return fetch(SandstormData, start, end, false, false, false)

  fetchDemoSandstorm: (start, end) ->
    return fetch(DemoSandstormData, start, end, false, false, false)

  fetchOasisSandstorm: (start, end) ->
    return fetch(OasisSandstormData, start, end, false, false, false)

  fetchLog: (start, end) ->
    filter =
      ip: {"$nin": Meteor.settings.logFilter.ips}
      client: {"$nin": Meteor.settings.logFilter.user_agents}
    return fetch(LogData, start, end, true, true, true, {fields: {timestamp: 1, type: 1}, filter: filter})

  fetchPreorders: (start, end) ->
    return fetch(Preorders, start, end, true, false, false)

  fetchOasisMonitorData: ->
    filter = {grainTitleResponsMs: {"$exists": true}, timestamp: {$gt: new Date(new Date().getTime() - 86400000)}}
    return fetch(OasisMonitorData, null, null, false, false, false, {filter: filter})

  fetchSandstormUserData: (start, end) ->
    return fetch(SandstormUserData, start, end, true, true, true)

dataCache = {}
@populateCache = ->
  for key, func of fetchMethods
    source = key.replace('fetch', '')
    dataCache[source] = func()

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

    return dataCache.Twitter or fetchMethods.fetchTwitter(start, end)

  fetchMailchimp: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.Mailchimp or fetchMethods.fetchMailchimp(start, end)

  fetchGoogle: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.Google or fetchMethods.fetchGoogle(start, end)

  fetchGithub: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

      return dataCache.Github or fetchMethods.fetchGithub(start, end)

  fetchSandstorm: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.Sandstorm or fetchMethods.fetchSandstorm(start, end)

  fetchDemoSandstorm: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.DemoSandstorm or fetchMethods.fetchDemoSandstorm(start, end)

  fetchOasisSandstorm: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.OasisSandstorm or fetchMethods.fetchOasisSandstorm(start, end)

  fetchLog: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.Log or fetchMethods.fetchLog(start, end)

  fetchPreorders: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.Preorders or fetchMethods.fetchPreorders(start, end)

  fetchOasisMonitorData: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.OasisMonitorData or fetchMethods.fetchOasisMonitorData(start, end)

  fetchSandstormUserData: (start, end) ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    return dataCache.sandstormUserData or fetchMethods.fetchSandstormUserData(start, end)
